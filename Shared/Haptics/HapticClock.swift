//
//  HapticClock.swift
//  Watch Vibration Test
//
//  Created by Dennis Moschina on 06.01.24.
//

import Foundation
import Combine

protocol HapticClock {
    var onFire: () -> () { get set }
    
    var clockRate: Double { get }
    var _clockRate: CurrentValueSubject<Double, Never> { get }
    
    func start()
    func stop()
}

extension HapticClock {
    var clockRate: Double {
        get { self._clockRate.value }
        set { self._clockRate.value = newValue }
    }
}
