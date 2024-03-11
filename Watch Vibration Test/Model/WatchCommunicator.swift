//
//  WatchCommunicator.swift
//  Watch Vibration Test
//
//  Created by Dennis Moschina on 16.11.23.
//

import Foundation
import WatchConnectivity
import OSLog
import HealthKit

class WatchCommunicator: NSObject, WCSessionDelegate, ObservableObject {
    private static let logger: Logger = Logger(subsystem: "edu.teco.moschina.WatchVibrationTest-Watch", category: "WatchCommunicator")
    static let shared: WatchCommunicator = WatchCommunicator()
    
    private let wcSession: WCSession
    
    var onFileReceive: [(WCSessionFile) -> ()] = []
    
    @Published var availablePatterns: [HapticPattern] = []
    @Published var availableHaptics: [Haptic] = []
    
    private var reachabilityContinuation: CheckedContinuation<Bool, Never>?
    
    private override init() {
        self.wcSession = WCSession.default
        super.init()
        self.wcSession.delegate = self
        self.wcSession.activate()
    }
    
    func startStudy(type: StudyType) async -> UUID? {
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = .mindAndBody
        configuration.locationType = .indoor
        
        let hkStore = HKHealthStore()
        do {
            try await hkStore.startWatchApp(toHandle: configuration)
        } catch {
            Self.logger.error("failed to start Watch App \(error)")
            return nil
        }
        
        if !self.wcSession.isReachable {
            guard await withCheckedContinuation({ continuation in
                self.reachabilityContinuation = continuation
            }) else {
                Self.logger.info("session not reachable")
                return nil
            }
        }
        
        return await withCheckedContinuation { continuation in
            //TODO: use `updateApplicationContext()` instead
            self.wcSession.sendMessage([MessageKeys.startStudy.rawValue : true, MessageKeys.type.rawValue : type.rawValue], replyHandler: { replyMessage in
                Self.logger.debug("received \(replyMessage) as a reply from `startStudy`")
                
                if let idString = replyMessage[MessageKeys.startStudy.rawValue] as? String {
                    guard let id = UUID(uuidString: idString) else {
                        Self.logger.error("failed to create UUID from \(idString)")
                        continuation.resume(returning: nil)
                        return
                    }
                    continuation.resume(returning: id)
                } else if let success = replyMessage[MessageKeys.startStudy.rawValue] as? Bool, !success {
                    Self.logger.error("failed to start study session")
                    continuation.resume(returning: nil)
                } else {
                    continuation.resume(returning: nil)
                }
            }) { error in
                Self.logger.error("failed to send start study signal \(error)")
                continuation.resume(returning: nil)
            }
        }
    }
    
    func sendActivity(_ activity: StudyActivity) async -> Bool {
        Self.logger.debug("sending new activity")
        
        return await withCheckedContinuation { continuation in
            self.wcSession.sendMessage([MessageKeys.activity.rawValue : activity.string]) { reply in
                guard let activityString = reply[MessageKeys.activity.rawValue] as? String, activityString == activity.string else {
                    Self.logger.info("unexpected reply after activity change \(reply)")
                    
                    continuation.resume(returning: false)
                    return
                }
                continuation.resume(returning: true)
            } errorHandler: { error in
                Self.logger.error("failed to send activity")
                continuation.resume(returning: false)
            }

        }
    }
    
    func stopStudy() async -> Bool {
        return await withCheckedContinuation { continuation in
            self.wcSession.sendMessage([MessageKeys.stopStudy.rawValue : true], replyHandler: { replyMessage in
                let stop = replyMessage[MessageKeys.stopStudy.rawValue] as? Bool ?? false
                continuation.resume(returning: stop)
            }) { error in
                Self.logger.error("Failed to send stop signal \(error)")
                continuation.resume(returning: false)
            }
        }
    }
    
    // MARK: Delegate methods
    
    internal func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        Self.logger.info("activation completed: \(activationState.rawValue)")
        return
    }
    
    internal func sessionDidBecomeInactive(_ session: WCSession) {
        return
    }
    
    internal func sessionDidDeactivate(_ session: WCSession) {
        return
    }
    
    internal func sessionReachabilityDidChange(_ session: WCSession) {
        Self.logger.debug("reachability changed to \(session.isReachable)")
        
        self.reachabilityContinuation?.resume(returning: session.isReachable)
        self.reachabilityContinuation = nil
    }
    
    internal func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        Self.logger.debug("received application context: \(applicationContext)")
    }
    
    internal func session(_ session: WCSession, didReceive file: WCSessionFile) {
        Self.logger.info("received file \(file)")
        
        self.onFileReceive.forEach { $0(file) }
    }
}
