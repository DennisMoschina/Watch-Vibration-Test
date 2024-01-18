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
    let clockRateLogger: CSVLogger
    
    var running: Bool = false
    
    mutating func start() {
        self.heartRateLogger.startRecording()
        self.activityLogger.startRecording()
        self.clockRateLogger.startRecording()
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
        let id = UUID()
        guard let folderURL = self.createPath(uuidString: id.uuidString) else {
            Self.logger.error("Failed to create folder from UUID \(id)")
            return nil
        }
        
        let detailFilePath = folderURL.appendingPathComponent("\(FileNames.detail.rawValue).txt")
        FileManager.default.createFile(atPath: detailFilePath.path, contents: detail.data(using: .utf8))
        
        var study = StudyLogger(
            id: id,
            folderURL: folderURL,
            detail: detail,
            heartRateLogger: CSVLogger(folderPath: folderURL.path, fileName: FileNames.heartRate.rawValue, header: ["timestamp", "heartRate"]),
            activityLogger: CSVLogger(folderPath: folderURL.path, fileName: FileNames.label.rawValue, header: ["timestamp", "activity"]),
            clockRateLogger: CSVLogger(folderPath: folderURL.path, fileName: FileNames.clockRate.rawValue, header: ["timestamp", "clockRate"])
        )
        
        setupHeartRateLogging(for: study)
        setupActivityLogging(for: study)
        setupClockRateLogging(for: study)
        study.start()
        
        DispatchQueue.main.async {
            self.study = study
        }
        
        self.startSession()
        
        return study.id
    }

    private func setupHeartRateLogging(for study: StudyLogger) {
        let heartRateSink = HeartRateSensor.shared.$timedHeartRate.sink { timedHeartRate in
            guard let timestamp = timedHeartRate?.timestamp, let heartRate = timedHeartRate?.heartRate else {
                Self.logger.info("Timed heart rate is nil")
                return
            }
            study.heartRateLogger.writeLine(data: [timestamp.timeIntervalSince1970, heartRate])
        }
        self.cancellables.append(heartRateSink)
    }

    private func setupActivityLogging(for study: StudyLogger) {
        let activitySink = StudyActivityManager.shared.$activity.sink { activity in
            study.activityLogger.writeLine(data: [String(format: "%f", Date().timeIntervalSince1970), activity.string])
            
            switch activity {
            case .pattern(pattern: let pattern):
                Self.logger.debug("Activity changed to pattern")
                self.hapticManager?.stop()
                self.hapticManager?.play(pattern: pattern)
            default:
                self.hapticManager?.stop()
            }
        }
        self.cancellables.append(activitySink)
    }

    private func setupClockRateLogging(for study: StudyLogger) {
        let patterns = StudyActivityManager.shared.process?.activities.compactMap { activity -> HapticPattern? in
            if case .pattern(pattern: let hapticPattern) = activity {
                return hapticPattern
            }
            return nil
        }
        
        let clockRateSinks = patterns?.map { pattern in
            pattern.clock._clockRate.sink { clockRate in
                self.study?.clockRateLogger.writeLine(data: [Date().timeIntervalSince1970, clockRate])
            }
        } ?? []
        
        self.cancellables.append(contentsOf: clockRateSinks)
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
        Self.logger.info("stopping workout")
        
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
