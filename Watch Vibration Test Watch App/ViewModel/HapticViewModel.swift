//
//  HapticViewModel.swift
//  Watch Vibration Test Watch App
//
//  Created by Dennis Moschina on 07.11.23.
//

import Foundation

class HapticViewModel: ObservableObject {
    @Published var playing: Bool = false
    @Published var frequency: Double = 60
    @Published var availableHaptics: [Haptic]
    @Published var scheduledHaptics: [Haptic] = []
    
    private let hapticManager: HapticManager
    
    init(hapticManager: HapticManager) {
        self.hapticManager = hapticManager
        self.availableHaptics = hapticManager.availableHaptics
    }
    
    func play(haptic: Haptic) {
        self.hapticManager.play(haptic: haptic)
        self.playing = false
    }
    
    func startPlaying() {
        self.hapticManager.playRepeated(haptics: self.scheduledHaptics, frequency: self.frequency)
        self.playing = true
    }
    
    func stop() {
        self.hapticManager.stop()
        self.playing = false
    }
}
