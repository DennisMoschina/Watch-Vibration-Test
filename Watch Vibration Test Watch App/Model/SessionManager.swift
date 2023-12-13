//
//  SessionManager.swift
//  Watch Vibration Test Watch App
//
//  Created by Dennis Moschina on 10.12.23.
//

import Foundation
import WatchKit
import OSLog

class SessionManager: NSObject, WKExtendedRuntimeSessionDelegate {
    private static let logger: Logger = Logger(subsystem: "edu.teco.moschina.Watch-Vibration-Test.watchkitapp", category: "SessionManager")
    
    public static let shared: SessionManager = SessionManager()
    
    private var session: WKExtendedRuntimeSession?
    
    func startSession() {
        self.session = WKExtendedRuntimeSession()
        self.session?.delegate = self
        
        self.session?.start()
        HeartRateSensor.shared.start()
        HealthKitManager.shared.startWorkout()
    }
    
    func stopSession() {
        self.session?.invalidate()
        HeartRateSensor.shared.stop()
    }

    func extendedRuntimeSession(_ extendedRuntimeSession: WKExtendedRuntimeSession, didInvalidateWith reason: WKExtendedRuntimeSessionInvalidationReason, error: Error?) {
        Self.logger.info("extended runtime session expired with reason \(reason.rawValue) and error \(error)")
    }
    
    func extendedRuntimeSessionDidStart(_ extendedRuntimeSession: WKExtendedRuntimeSession) {
        Self.logger.debug("started extended runtime session")
    }
    
    func extendedRuntimeSessionWillExpire(_ extendedRuntimeSession: WKExtendedRuntimeSession) {
        Self.logger.info("extended runtime session will expire")
    }
}
