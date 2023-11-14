//
//  HapticViewModel.swift
//  Watch Vibration Test Watch App
//
//  Created by Dennis Moschina on 07.11.23.
//

import Foundation
import Combine
import SwiftUI

enum AppNavigation: Hashable {
    case playSingleList
    case patternList
    case playPattern(pattern: HapticPattern)
    case editPattern(pattern: HapticPattern)
}

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
    
    func play(pattern: HapticPattern, for time: TimeInterval? = nil) {
        self.hapticManager.play(pattern: pattern, for: time)
        self.navigation.append(AppNavigation.playPattern(pattern: pattern))
    }
    
    func stop() {
        self.hapticManager.stop()
        self.navigation.removeLast()
    }
}
