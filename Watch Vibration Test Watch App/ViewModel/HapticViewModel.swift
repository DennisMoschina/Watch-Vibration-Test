//
//  HapticViewModel.swift
//  Watch Vibration Test Watch App
//
//  Created by Dennis Moschina on 07.11.23.
//

import Foundation
import Combine
import SwiftUI

class HapticViewModel: ObservableObject {
    @Published var frequency: Double = 60
    @Published var availableHaptics: [Haptic]
    
    @Published var navigation: NavigationPath = NavigationPath()
    
    private let hapticManager: HapticManager
    
    private var cancellables: [AnyCancellable] = []
    
    init(hapticManager: HapticManager) {
        self.hapticManager = hapticManager
        self.availableHaptics = hapticManager.availableHaptics
    }
    
    func play(haptic: Haptic) {
        self.hapticManager.play(haptic: haptic)
    }
    
    func play(pattern: HapticPattern) {
        self.hapticManager.play(pattern: pattern) { pattern in
            self.navigation.removeLast()
        }
        self.navigation.append(PatternNavigation.play(pattern: pattern))
    }
    
    func stop() {
        self.hapticManager.stop()
        self.navigation.removeLast()
    }
}
