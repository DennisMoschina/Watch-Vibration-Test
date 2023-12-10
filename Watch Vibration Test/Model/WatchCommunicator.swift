//
//  WatchCommunicator.swift
//  Watch Vibration Test
//
//  Created by Dennis Moschina on 16.11.23.
//

import Foundation
import WatchConnectivity
import OSLog

class WatchCommunicator: NSObject, WCSessionDelegate, ObservableObject {
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
        self.wcSession.sendMessage([MessageKeys.playHaptic.rawValue : encodedHaptic], replyHandler: nil)
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
    
    internal func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        Self.logger.debug("received application context: \(applicationContext)")
        
        if let patterns: [HapticPattern] = applicationContext[MessageKeys.patterns.rawValue] as? [HapticPattern] {
            Self.logger.debug("got patterns: \(patterns)")
            self.availablePatterns = patterns
        }
    }
}
