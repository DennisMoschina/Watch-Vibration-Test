//
//  SessionManager.swift
//  Watch Vibration Test Watch App
//
//  Created by Dennis Moschina on 10.12.23.
//

import Foundation
import WatchKit
import OSLog
import Combine

struct Study {
    let id: UUID
    let folderURL: URL
    
    let heartRateLogger: CSVLogger
    let activityLogger: CSVLogger
    
    var running: Bool = false
    
    mutating func start() {
        self.heartRateLogger.startRecording()
        self.activityLogger.startRecording()
        self.running = true
    }
    
    mutating func stop() {
        self.heartRateLogger.stopRecording()
        self.activityLogger.stopRecording()
        self.running = false
    }
}

class SessionManager: NSObject, ObservableObject {
    private static let logger: Logger = Logger(subsystem: "edu.teco.moschina.Watch-Vibration-Test.watchkitapp", category: "SessionManager")
    
    public static let shared: SessionManager = SessionManager()
    
    @Published private(set) var study: Study?
    
    private var cancellables: [AnyCancellable?] = []
    
    private override init() { }
    
    func startStudy() -> UUID? {
        //TODO: implement
        let id = UUID()
        guard let folderURL = self.createPath(uuidString: id.uuidString) else {
            Self.logger.error("failed to create folder from UUID \(id)")
            return nil
        }
        
        DispatchQueue.main.sync {
            self.study = Study(
                id: id,
                folderURL: folderURL,
                heartRateLogger: CSVLogger(folderPath: folderURL.path(), fileName: "heartRate", header: ["timestamp", "heartRate"]),
                activityLogger: CSVLogger(folderPath: folderURL.path(), fileName: "label", header: ["timestamp", "activity"])
            )
        }
        
        self.cancellables.append(contentsOf: [
            HeartRateSensor.shared.$timedHeartRate.sink { timedHeartRate in
                guard let timestamp = timedHeartRate?.timestamp, let heartRate = timedHeartRate?.heartRate else {
                    Self.logger.info("timed heart rate is nil")
                    return
                }
                
                self.study?.heartRateLogger.writeLine(data: [timestamp.timeIntervalSince1970, heartRate])
            },
            StudyActivityManager.shared.$activity.sink{ activity in
                self.study?.activityLogger.writeLine(data: [String(format: "%f", Date().timeIntervalSince1970), activity.string])
            }
        ])
        
        DispatchQueue.main.async {
            self.study?.start()
        }
        self.startSession()
        return self.study!.id
    }
    
    /**
     * Stop the currently running study
     * returns: url to the folder of the study
     */
    func stopStudy() -> URL? {
        defer {
            DispatchQueue.main.async {
                self.study?.stop()
                self.study = nil
            }
        }
        
        self.stopSession()
        return self.study?.folderURL
    }
    
    func startSession() {
        HeartRateSensor.shared.start()
        HealthKitManager.shared.startWorkout()
    }
    
    func stopSession() {
        HeartRateSensor.shared.stop()
        HealthKitManager.shared.stopWorkout()
    }
    
    private func createPath(uuidString: String) -> URL? {
        do {
            let dir = FileManager.default.urls(
                for: .documentDirectory,
                in: .userDomainMask
            ).first!
            
            let folder = "session_" + uuidString
            let folderURL = dir.appendingPathComponent(folder)
            try FileManager.default.createDirectory(at: folderURL,withIntermediateDirectories: true)
            return folderURL
        } catch let e {
            Self.logger.error("failed to create folder \(e)")
        }
        return nil
    }
}
