//
//  HeartRateClock.swift
//  Watch Vibration Test Watch App
//
//  Created by Dennis Moschina on 06.01.24.
//

import Foundation
import Combine
import OSLog

class HeartRateClock: HapticClock {
    private static let logger: Logger = Logger(subsystem: "edu.teco.moschina.Watch-Vibration-Test.watchkitapp", category: "HeartRateClock")

    var onFire: () -> ()
    var _clockRate: CurrentValueSubject<Double, Never> = CurrentValueSubject(0)
    
    private var heartRateSensor: HeartRateSensor
    
    private var heartRateFactor: Double
    private var updateInterval: TimeInterval
    
    private var timedHeartRateCancellable: AnyCancellable?
    
    private var hapticTimer: Timer?
    private var updateTimer: Timer?
    
    private var updatedTimerInterval: TimeInterval?
    
    init(heartRateSensor: HeartRateSensor, heartRateFactor: Double = 0.96, updateInterval: TimeInterval = 30, onFire: @escaping () -> Void = { }) {
        self.heartRateSensor = heartRateSensor
        self.heartRateFactor = heartRateFactor
        self.updateInterval = updateInterval
        self.onFire = onFire
    }
    
    func start() {
        self.heartRateSensor.start()
        self.updateTimer?.invalidate()
        self.updateAverage()
        self.updateTimer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true, block: { _ in
            self.updateAverage()
        })
        
        self.scheduleHapticTimer()
        
    }
    
    func stop() {
        self.updateTimer?.invalidate()
        self.hapticTimer?.invalidate()
        self._clockRate.value = 0
    }
    
    private func updateAverage() {
        Task {
            let average = await self.heartRateSensor.getAverage(for: 30)
            Self.logger.debug("average heartRate: \(average) bpm")
            guard average > 0 else {
                Self.logger.error("\(average) bpm is not a valid heart rate")
                return
            }
            let targetHeartRate = average * heartRateFactor
            self.updatedTimerInterval = 60.0 / targetHeartRate
            self._clockRate.value = targetHeartRate
            Self.logger.debug("new clockRate is \(self.clockRate) bpm")
        }
    }
    
    private func scheduleHapticTimer() {
        self.hapticTimer?.invalidate()
        self.hapticTimer = Timer.scheduledTimer(withTimeInterval: self.updatedTimerInterval ?? 1, repeats: true, block: { timer in
            self.onFire()
            if self.updatedTimerInterval != nil {
                timer.invalidate()
                self.scheduleHapticTimer()
            }
        })
        self.updatedTimerInterval = nil
    }
}
