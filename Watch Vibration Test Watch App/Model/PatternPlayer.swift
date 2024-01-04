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
    
    @Published var playing: Bool = false
    
    init(pattern: HapticPattern) {
        self.pattern = pattern
    }
    
    func play() {
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
        if self.pattern.automaticStop {
            self.turnOffTimer = Timer.scheduledTimer(withTimeInterval: self.pattern.duration, repeats: false, block: { _ in
                self.stop()
            })
        }
        self.playing = true
    }
    
    func stop() {
        self.timer?.invalidate()
        self.playing = false
    }
}
