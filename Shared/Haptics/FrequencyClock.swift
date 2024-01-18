//
//  FrequencyClock.swift
//  Watch Vibration Test
//
//  Created by Dennis Moschina on 06.01.24.
//

import Foundation
import Combine

class FrequencyClock: HapticClock {
    var frequency: Int
    
    private var timer: Timer?
    
    var onFire: () -> Void
    
    var _clockRate: CurrentValueSubject<Double, Never> = CurrentValueSubject(0)
    
    init(frequency: Int = 60, onFire: @escaping () -> Void = { }) {
        self.frequency = frequency
        self.onFire = onFire
    }
    
    func start() {
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(withTimeInterval: 60.0 / Double(self.frequency), repeats: true, block: { _ in
            self.onFire()
        })
        self._clockRate.value = Double(self.frequency)
    }
    
    func stop() {
        self.timer?.invalidate()
        self._clockRate.value = 0
    }
}
