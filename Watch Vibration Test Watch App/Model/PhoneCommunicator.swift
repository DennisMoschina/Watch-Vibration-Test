//
//  PhoneCommunicator.swift
//  Watch Vibration Test Watch App
//
//  Created by Dennis Moschina on 19.11.23.
//

import Foundation
import WatchConnectivity
import OSLog


class PhoneCommunicator: NSObject, WCSessionDelegate {
    private static let logger: Logger = Logger(subsystem: "edu.teco.moschina.WatchVibrationTest-Watch", category: "WatchCommunicator")

    static let shared: PhoneCommunicator = PhoneCommunicator()
    
    private let wcSession: WCSession
    
    var hapticManager: HapticManager? {
        didSet {
            Self.logger.debug("did set hapticManager")
        }
    }
    
    private override init() {
        self.wcSession = WCSession.default
        super.init()
        self.wcSession.delegate = self
        self.wcSession.activate()
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        Self.logger.info("activation completed: \(activationState.rawValue)")
        return
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        Self.logger.debug("received: \(message)")
        if let hapticData = message["play_haptic"] as? Data {
            let decoder = JSONDecoder()
            if let haptic: Haptic = try? decoder.decode(Haptic.self, from: hapticData) {
                self.hapticManager?.play(haptic: haptic)
            } else {
                Self.logger.error("failed to decode haptic")
            }
        }
    }
}
