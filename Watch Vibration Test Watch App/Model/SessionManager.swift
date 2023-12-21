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

struct StudyLogger: Hashable {
    static func == (lhs: StudyLogger, rhs: StudyLogger) -> Bool {
        lhs.id == rhs.id
    }
    
    let id: UUID
    let folderURL: URL
    
    var detail: String = ""
    var startDate: Date = Date()
    
    let heartRateLogger: CSVLogger
    let activityLogger: CSVLogger
    
    var running: Bool = false
    
    mutating func start() {
        self.heartRateLogger.startRecording()
        self.activityLogger.startRecording()
        self.running = true
        self.startDate = Date()
    }
    
    mutating func stop() {
        self.heartRateLogger.stopRecording()
        self.activityLogger.stopRecording()
        self.running = false
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
        hasher.combine(self.folderURL)
    }
}

class SessionManager: NSObject, ObservableObject {
    private static let logger: Logger = Logger(subsystem: "edu.teco.moschina.Watch-Vibration-Test.watchkitapp", category: "SessionManager")
    
    public static let shared: SessionManager = SessionManager()
    
    @Published private(set) var study: StudyLogger?
    
    var hapticManager: HapticManager?

    private var cancellables: [AnyCancellable?] = []
    
    private override init() { }
    
    func startStudy(detail: String = "") -> UUID? {
        //TODO: implement
        let id = UUID()
        guard let folderURL = self.createPath(uuidString: id.uuidString) else {
            Self.logger.error("failed to create folder from UUID \(id)")
            return nil
        }
        
        var study = StudyLogger(
            id: id,
            folderURL: folderURL,
            detail: detail,
            heartRateLogger: CSVLogger(folderPath: folderURL.path(), fileName: "heartRate", header: ["timestamp", "heartRate"]),
            activityLogger: CSVLogger(folderPath: folderURL.path(), fileName: "label", header: ["timestamp", "activity"])
        )
        
        
        
        self.cancellables.append(contentsOf: [
            HeartRateSensor.shared.$timedHeartRate.sink { timedHeartRate in
                guard let timestamp = timedHeartRate?.timestamp, let heartRate = timedHeartRate?.heartRate else {
                    Self.logger.info("timed heart rate is nil")
                    return
                }
                
                study.heartRateLogger.writeLine(data: [timestamp.timeIntervalSince1970, heartRate])
            },
            StudyActivityManager.shared.$activity.sink { activity in
                study.activityLogger.writeLine(data: [String(format: "%f", Date().timeIntervalSince1970), activity.string])
            },
            StudyActivityManager.shared.$activity.sink { activity in
                switch activity {
                case .pattern(pattern: let pattern):
                    self.hapticManager?.stop()
                    self.hapticManager?.play(pattern: pattern, onEnd: { _ in
                        StudyActivityManager.shared.activity = .none
                    })
                default:
                    self.hapticManager?.stop()
                }
            }
        ])
        study.start()
        
        DispatchQueue.main.async {
            self.study = study
        }
        
        self.startSession()
        
        return study.id
    }
    
    /**
     * Stop the currently running study
     * returns: url to the folder of the study
     */
    func stopStudy() -> StudyLogger? {
        defer {
            DispatchQueue.main.async {
                self.study?.stop()
                self.study = nil
            }
        }
        
        self.hapticManager?.stop()
        
        self.stopSession()
        return self.study
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
