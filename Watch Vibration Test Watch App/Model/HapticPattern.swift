//
//  HapticPattern.swift
//  Watch Vibration Test Watch App
//
//  Created by Dennis Moschina on 08.11.23.
//

import Foundation

struct HapticPattern: IteratorProtocol {
    typealias Element = Haptic
    
    var haptics: [Haptic]
    var frequency: Double
    
    private var hapticIndex: Int = 0
    
    mutating func next() -> Haptic? {
        guard self.haptics.count > 0 else { return nil }
        let next = haptics[self.hapticIndex]
        self.hapticIndex = (self.hapticIndex + 1) % self.haptics.count
        return next
    }
}
