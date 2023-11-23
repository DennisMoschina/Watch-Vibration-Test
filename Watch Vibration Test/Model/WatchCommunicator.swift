//
//  WatchCommunicator.swift
//  Watch Vibration Test
//
//  Created by Dennis Moschina on 16.11.23.
//

import Foundation
import WatchConnectivity
import OSLog

class WatchCommunicator: NSObject, WCSessionDelegate {
    private static let logger: Logger = Logger(subsystem: "edu.teco.moschina.WatchVibrationTest-Watch", category: "WatchCommunicator")
    static let shared: WatchCommunicator = WatchCommunicator()
    
    private let wcSession: WCSession
    
    @Published var availablePatterns: [HapticPattern] = []
    @Published var availableHaptics: [Haptic] = []
    
    private override init() {
        self.wcSession = WCSession.default
        super.init()
        self.wcSession.delegate = self
        self.wcSession.activate()
    }
    
    func play(haptic: Haptic) {
        guard self.wcSession.isReachable, self.wcSession.activationState == .activated else {
            Self.logger.error("Watch is not reachable or not activated")
            return
        }
        Self.logger.debug("send command to play haptic: \(haptic.name)")
        let encoder = JSONEncoder()
        guard let encodedHaptic = try? encoder.encode(haptic) else {
            Self.logger.error("failed to encode haptic")
            return
        }
        Self.logger.debug("encoded: \(encodedHaptic)")
        self.wcSession.sendMessage(["play_haptic" : encodedHaptic], replyHandler: nil)
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        Self.logger.info("activation completed: \(activationState.rawValue)")
        return
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        return
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        return
    }
}
