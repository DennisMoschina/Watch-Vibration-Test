//
//  HeartRateSensor.swift
//  Watch Vibration Test Watch App
//
//  Created by Dennis Moschina on 13.12.23.
//

import Foundation
import HealthKit
import OSLog

class HeartRateSensor: ObservableObject {
    private static let logger: Logger = Logger(subsystem: "edu.teco.moschina.Watch-Vibration-Test.watchkitapp", category: "HeartRateSensor")
    
    public static let shared = HeartRateSensor()

    @Published var heartRate: Double = 0
    @Published var timedHeartRate: (heartRate: Double, timestamp: Date)?
    
    private var heartRateQuery: HKAnchoredObjectQuery?
    
    func start() {
        guard let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate) else {
            Self.logger.error("failed to get `HKObjectType` for heartRate")
            return
        }
        
        let predicate = HKQuery.predicateForSamples(withStart: Date(), end: nil)
        self.heartRateQuery = HKAnchoredObjectQuery(type: heartRateType, predicate: predicate, anchor: nil, limit: HKObjectQueryNoLimit) { query, samples, deletedObjects, anchor, error in
            if let error {
                Self.logger.error("failed to get heartRate \(error)")
                return
            }
            
            if let samples {
                self.process(samples)
            }
        }
        
        self.heartRateQuery?.updateHandler = { query, samples, deletedObjects, anchor, error in
            if let error {
                Self.logger.error("failed to get heartRate \(error)")
                return
            }
            
            if let samples {
                self.process(samples)
            }
        }
        
        if let query = self.heartRateQuery {
            HealthKitManager.shared.execute(query)
        }
    }
    
    func stop() {
        if let query = self.heartRateQuery {
            HealthKitManager.shared.stop(query: query)
        }
    }
    
    private func process(_ samples: [HKSample]) {
        guard
            let samples = samples as? [HKQuantitySample],
            let sample = samples.last
        else {
            Self.logger.error("failed to cast samples")
            return
        }
        
        self.heartRate = sample.quantity.doubleValue(for: HKUnit(from: "count/min"))
        self.timedHeartRate = (heartRate: self.heartRate, timestamp: sample.startDate)
        Self.logger.debug("heartRate: \(self.heartRate) bpm")
    }
}
