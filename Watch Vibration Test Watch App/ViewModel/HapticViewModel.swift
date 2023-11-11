//
//  HapticViewModel.swift
//  Watch Vibration Test Watch App
//
//  Created by Dennis Moschina on 07.11.23.
//

import Foundation
import Combine

class HapticViewModel: ObservableObject {
    @Published var playing: Bool = false
    @Published var frequency: Double = 60
    @Published var availableHaptics: [Haptic]
    
    @Published var availablePatterns: [HapticPattern] = []
    
    private let hapticManager: HapticManager
    
    private var cancellables: [AnyCancellable] = []
    
    init(hapticManager: HapticManager) {
        self.hapticManager = hapticManager
        self.availableHaptics = hapticManager.availableHaptics
        self.cancellables.append(self.hapticManager.$playing.sink(receiveValue: { playing in
            self.playing = playing
        }))
    }
    
    func play(haptic: Haptic) {
        self.hapticManager.play(haptic: haptic)
        self.playing = false
    }
    
    func play(pattern: HapticPattern, for time: TimeInterval? = nil) {
        self.hapticManager.play(pattern: pattern, for: time)
    }
    
    func stop() {
        self.hapticManager.stop()
    }
    
    func addPattern() {
        
    }
}
