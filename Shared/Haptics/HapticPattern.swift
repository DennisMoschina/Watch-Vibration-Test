//
//  HapticPattern.swift
//  Watch Vibration Test Watch App
//
//  Created by Dennis Moschina on 08.11.23.
//

import Foundation
import SwiftData

@Model
final class HapticPattern: Identifiable {
    static var patternCount: UInt = 0
    
    var name: String = ""
    var haptics: [Haptic] = []
    var frequency: Int = 60
    
    init(name: String? = nil, haptics: [Haptic] = [], frequency: Int = 60) {
        if let name { self.name = name }
        else {
            self.name = "Pattern \(Self.patternCount)"
            Self.patternCount += 1
        }
        self.haptics = haptics
        self.frequency = frequency
    }
}
