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
    
    @Published var playingPattern: HapticPattern?
    
    private let device: WKInterfaceDevice = WKInterfaceDevice.current()
    
    private var playTimer: Timer?
    private var turnOffTimer: Timer?
    
    private(set) var availableHaptics: [Haptic] = Haptic.defaults
    private(set) var availablePatterns: [HapticPattern] = []
    
    func play(haptic: Haptic) {
        if let type = haptic.hapticType {
            self.device.play(type)
        }
    }
    
    func play(pattern: HapticPattern, for time: TimeInterval? = nil) {
        var patternCopy = pattern
        self.playTimer = Timer.scheduledTimer(withTimeInterval: 1.0 / Double(pattern.frequency), repeats: true, block: { _ in
            guard let haptic = patternCopy.next() else {
                Self.logger.error("failed to get haptic from pattern")
                return
            }
            self.play(haptic: haptic)
        })
        if let time {
            self.turnOffTimer = Timer.scheduledTimer(withTimeInterval: time, repeats: false, block: { _ in
                self.playTimer?.invalidate()
                self.playingPattern = nil
            })
        }
        self.playingPattern = pattern
    }
    
    func stop() {
        self.playTimer?.invalidate()
        self.playingPattern = nil
    }
}
