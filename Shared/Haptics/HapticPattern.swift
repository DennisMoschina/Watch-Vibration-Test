//
//  HapticPattern.swift
//  Watch Vibration Test Watch App
//
//  Created by Dennis Moschina on 08.11.23.
//

import Foundation
import SwiftData

final class HapticPattern: Identifiable, Equatable {
    static func == (lhs: HapticPattern, rhs: HapticPattern) -> Bool {
        lhs.name == rhs.name
    }
    
    static var patternCount: UInt = 0
    
    var name: String = ""
    var haptics: [Haptic] = []
    var frequency: Int = 60
    var duration: TimeInterval = 300
    var automaticStop: Bool = false
    
    init(name: String? = nil, haptics: [Haptic] = [], frequency: Int = 60, duration: TimeInterval = 300, automaticStop: Bool = false) {
        if let name { self.name = name }
        else {
            self.name = "Pattern \(Self.patternCount)"
            Self.patternCount += 1
        }
        self.haptics = haptics
        self.frequency = frequency
        self.duration = duration
        self.automaticStop = automaticStop
    }
    
    static var defaults: [HapticPattern] = [
        HapticPattern(name: "Tap", haptics: [Haptic.defaults.first(where: { $0.name == "Start" })!]),
        HapticPattern(name: "Vibration", haptics: [Haptic.defaults.first(where: { $0.name == "Failure" })!]),
        HapticPattern(name: "Alteration", haptics: [Haptic.defaults.first(where: { $0.name == "Start" })!, Haptic.defaults.first(where: { $0.name == "Failure" })!]),
        HapticPattern(name: "6/8 Alteration", haptics: [Haptic.defaults.first(where: { $0.name == "Start" })!, Haptic.defaults.first(where: { $0.name == "Start" })!, Haptic.defaults.first(where: { $0.name == "Failure" })!]),
        HapticPattern(name: "6/8 Alteration 2", haptics: [Haptic.defaults.first(where: { $0.name == "Start" })!, Haptic.defaults.first(where: { $0.name == "Failure" })!, Haptic.defaults.first(where: { $0.name == "Failure" })!])
    ]
}
