//
//  HapticManager.swift
//  Watch Vibration Test Watch App
//
//  Created by Dennis Moschina on 07.11.23.
//

import Foundation
import WatchKit
import OSLog
import Combine

class HapticManager {
    private static let logger: Logger = Logger(subsystem: "edu.teco.moschina.Watch-Vibration-Test.watchkitapp", category: "HapticManager")
    
    @Published var patternPlayer: PatternPlayer?
    
    private let device: WKInterfaceDevice = WKInterfaceDevice.current()
    
    private var turnOffTimer: Timer?
    
    private(set) var availableHaptics: [Haptic] = Haptic.defaults
    private(set) var availablePatterns: [HapticPattern] = []
    
    private var cancellables: [AnyCancellable?] = []
    
    func play(haptic: Haptic) {
        if let type = haptic.hapticType {
            self.device.play(type)
        }
    }
    
    func play(pattern: HapticPattern, onEnd: @escaping (HapticPattern) -> Void = {_ in }) {
        self.patternPlayer = PatternPlayer(pattern: pattern)
        self.patternPlayer?.play()
        self.cancellables.append(self.patternPlayer?.$playing.sink(receiveValue: { [weak pattern] playing in
            if !playing, let pattern {
                onEnd(pattern)
            }
        }))
    }
    
    func stop() {
        self.patternPlayer?.stop()
    }
}
