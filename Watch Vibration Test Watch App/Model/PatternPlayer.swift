//
//  PatternPlayer.swift
//  Watch Vibration Test
//
//  Created by Dennis Moschina on 24.11.23.
//

import Foundation
import OSLog
import WatchKit

class PatternPlayer {
    private static let logger: Logger = Logger(subsystem: "edu.teco.moschina.Watch-Vibration-Test.watchkitapp", category: "PatternPlayer")
    
    private let pattern: HapticPattern
    
    private var timer: Timer?
    private var turnOffTimer: Timer?
    
    private var hapticIndex: Int = 0
    
    init(pattern: HapticPattern) {
        self.pattern = pattern
    }
    
    func play(for time: TimeInterval? = nil) {
        guard !self.pattern.haptics.isEmpty else {
            Self.logger.info("pattern is empty")
            return
        }
        self.timer = Timer.scheduledTimer(withTimeInterval: 60.0 / Double(pattern.frequency), repeats: true, block: { _ in
            self.hapticIndex %= self.pattern.haptics.count
            let haptic = self.pattern.haptics[self.hapticIndex]
            if let hapticType = haptic.hapticType {
                WKInterfaceDevice.current().play(hapticType)
            }
            self.hapticIndex += 1
        })
        if let time {
            self.turnOffTimer = Timer.scheduledTimer(withTimeInterval: time, repeats: false, block: { _ in
                self.timer?.invalidate()
            })
        }
    }
    
    func stop() {
        self.timer?.invalidate()
    }
}
