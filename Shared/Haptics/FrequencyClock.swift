//
//  FrequencyClock.swift
//  Watch Vibration Test
//
//  Created by Dennis Moschina on 06.01.24.
//

import Foundation

class FrequencyClock: HapticClock {
    var frequency: Int
    
    private var timer: Timer?
    
    var onFire: () -> Void
    
    init(frequency: Int = 60, onFire: @escaping () -> Void = { }) {
        self.frequency = frequency
        self.onFire = onFire
    }
    
    func start() {
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(withTimeInterval: 60.0 / Double(self.frequency), repeats: true, block: { _ in
            self.onFire()
        })
    }
    
    func stop() {
        self.timer?.invalidate()
    }
}
