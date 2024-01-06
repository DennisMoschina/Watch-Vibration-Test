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
        self.pattern.clock.onFire = {
            self.hapticIndex %= self.pattern.haptics.count
            let haptic = self.pattern.haptics[self.hapticIndex]
            if let hapticType = haptic.hapticType {
                WKInterfaceDevice.current().play(hapticType)
            }
            self.hapticIndex += 1
        }
        self.pattern.clock.start()
        if self.pattern.automaticStop {
            self.turnOffTimer = Timer.scheduledTimer(withTimeInterval: self.pattern.duration, repeats: false, block: { _ in
                self.stop()
            })
        }
        self.playing = true
    }
    
    func stop() {
        self.pattern.clock.stop()
        self.playing = false
    }
}
