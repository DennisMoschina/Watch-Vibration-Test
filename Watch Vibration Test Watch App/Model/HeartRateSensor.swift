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
    
    private var healthKitManager: HealthKitManager = HealthKitManager.shared
    
    private var heartRateQuery: HKAnchoredObjectQuery?
    private var isQueryRunning = false
    
    private init() { }
    
    func getAverage(for timeInterval: TimeInterval) async -> Double {
        guard let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate) else {
            Self.logger.error("failed to get quantityType for heartRate")
            return -1
        }

        let endDate = Date()
        let startDate = endDate.addingTimeInterval(-timeInterval)
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate)

        return await withCheckedContinuation { continuation in
            let query = HKStatisticsQuery(quantityType: heartRateType, quantitySamplePredicate: predicate, options: .discreteAverage) { _, result, _ in
                guard let result = result, let averageQuantity = result.averageQuantity() else {
                    Self.logger.error("failed to get average")
                    continuation.resume(returning: -1)
                    return
                }
                let averageHeartRate = averageQuantity.doubleValue(for: HKUnit(from: "count/min"))
                continuation.resume(returning: averageHeartRate)
            }

            self.healthKitManager.execute(query)
        }
    }
    
    func start() {
        guard !self.isQueryRunning else {
            Self.logger.debug("query already running")
            return
        }
        
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
            self.healthKitManager.execute(query)
            self.isQueryRunning = true
        }
    }
    
    func stop() {
        if let query = self.heartRateQuery {
            self.healthKitManager.stop(query: query)
            self.isQueryRunning = false
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
