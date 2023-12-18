//
//  HealthKitManager.swift
//  Watch Vibration Test
//
//  Created by Dennis Moschina on 13.12.23.
//

import Foundation
import HealthKit
import OSLog

class HealthKitManager: NSObject, HKWorkoutSessionDelegate, HKLiveWorkoutBuilderDelegate {
    private static let logger: Logger = Logger(subsystem: "edu.teco.moschina.Watch-Vibration-Test", category: "HealthKitManager")
    
    public static let shared: HealthKitManager = HealthKitManager()
    
    private let hkStore: HKHealthStore
    private var workoutSession: HKWorkoutSession?
    
    private var workoutBuilder: HKLiveWorkoutBuilder?
    
    private override init() {
        guard HKHealthStore.isHealthDataAvailable() else {
            fatalError("HealthKit is not available")
        }
        
        self.hkStore = HKHealthStore()
        super.init()
        Task {
            await self.requestAuthorization()
        }
    }
    
    func requestAuthorization() async {
        let types = Set([
            HKObjectType.workoutType(),
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.quantityType(forIdentifier: .restingHeartRate)!,
            HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!
        ])
        
        do {
            try await self.hkStore.requestAuthorization(toShare: [], read: types)
        } catch {
            Self.logger.error("failed to request HealthKit authorization \(error)")
        }
    }
    
    func startWorkout() {
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = .mindAndBody
        configuration.locationType = .indoor
        
        do {
            self.workoutSession = try HKWorkoutSession(healthStore: self.hkStore, configuration: configuration)
            self.workoutBuilder = self.workoutSession?.associatedWorkoutBuilder()
            self.workoutBuilder?.dataSource = HKLiveWorkoutDataSource(healthStore: self.hkStore, workoutConfiguration: configuration)
        } catch {
            Self.logger.error("failed to start workout \(error)")
            return
        }
        self.workoutSession?.delegate = self

        self.workoutBuilder?.delegate = self
        
        self.workoutSession?.startActivity(with: Date())
        self.workoutBuilder?.beginCollection(withStart: Date(), completion: { success, error in
            if let error {
                Self.logger.error("failed to collect workout data \(error)")
            }
        })
    }
    
    func stopWorkout() {
        self.workoutSession?.stopActivity(with: Date())
        self.workoutSession?.end()
    }
    
    func execute(_ query: HKQuery) {
        self.hkStore.execute(query)
    }
    
    func stop(query: HKQuery) {
        self.hkStore.stop(query)
    }
    
    // MARK: Delegate
    internal func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
        Self.logger.info("workout state changed to \(toState.rawValue)")
    }
    
    internal func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
        Self.logger.error("workout session failed \(error)")
    }

    internal func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {
        Self.logger.debug("workoutBuilder collected")
    }
    
    internal func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder, didCollectDataOf collectedTypes: Set<HKSampleType>) {
        //TODO: implement
    }
}
