//
//  HapticManager.swift
//  Watch Vibration Test Watch App
//
//  Created by Dennis Moschina on 07.11.23.
//

import Foundation
import WatchKit
import OSLog

class HapticManager {
    private static let logger: Logger = Logger(subsystem: "edu.teco.moschina.WatchVibrationTest-Watch", category: "HapticManager")
    
    private let device: WKInterfaceDevice = WKInterfaceDevice.current()
    
    private var playTimer: Timer?
    
    private var timerFirings: Int = 0
    
    private(set) var availableHaptics: [Haptic] = Haptic.defaults
    
    func play(haptic: Haptic) {
        if let type = haptic.hapticType {
            self.device.play(type)
        }
    }
    
    func playRepeated(haptics: [Haptic], frequency: Double) {
        self.playTimer?.invalidate()
        guard frequency > 0 else {
            Self.logger.warning("frequency must be greater than 0")
            return
        }
        self.playTimer = Timer.scheduledTimer(withTimeInterval: 1 / frequency, repeats: true, block: { _ in
            guard self.timerFirings < haptics.count else {
                Self.logger.error("failed to play haptic: index \(self.timerFirings) is out of range \(haptics.count - 1)")
                return
            }
            self.play(haptic: haptics[self.timerFirings])
            self.timerFirings += 1
            self.timerFirings %= haptics.count
        })
        self.timerFirings = 0
    }
    
    func stop() {
        self.playTimer?.invalidate()
        self.timerFirings = 0
    }
}
