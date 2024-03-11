//
//  StudyManager.swift
//  Watch Vibration Test
//
//  Created by Dennis Moschina on 14.12.23.
//

import Foundation
import SwiftData
import OSLog
import Combine

class StudyManager {
    private static let STUDY_DIR_PREFIX: String = "session_"
    
    private static let logger: Logger = Logger(subsystem: "edu.teco.moschina.WatchVibrationTest-Watch", category: "StudyManager")

    public static let shared: StudyManager = .init()
    
    private let watchCommunicator = WatchCommunicator.shared
    
    var study: StudyEntry?
    var communicationFailed: Bool = false
    
    private var cancellables: [AnyCancellable?] = []
    
    private var fileHandler: FileHandler = FileHandler.default
    
    var onStudyStarted: [() -> ()] = []
    var onStudyStopped: [() -> ()] = []
    
    private init() {
        self.cancellables.append(
            StudyActivityManager.shared.$activity.sink { activity in
                Task {
                    if !(await self.watchCommunicator.sendActivity(activity)) {
                        Self.logger.info("notifying clients about failed activity send")
                        DispatchQueue.main.async {
                            self.communicationFailed.toggle()
                        }
                    }
                }
            }
        )
    }
    
    func startStudy(detail: String, type: StudyType = .none) async -> Bool {
        if let id = await self.watchCommunicator.startStudy(type: type) {
            guard let folderPath = self.fileHandler.createPath(uuidString: id.uuidString) else {
                Self.logger.error("failed to create folderPath")
                return false
            }
            defer { self.onStudyStarted.forEach { $0() } }
            self.study = StudyEntry(detail: detail, id: id, folder: folderPath, startDate: Date(), studyType: type)
            SwiftDataStack.shared.modelContext.insert(self.study!)
            self.fileHandler.createFile(in: folderPath, fileName: "\(FileNames.detail.rawValue).txt", content: detail)
            return true
        } else {
            return false
        }
    }
    
    func stopStudy() async -> Bool {
        let stopped = await self.watchCommunicator.stopStudy()
        if stopped { self.onStudyStopped.forEach { $0() } }
        return stopped
    }
    
    func registerTappingTaskTap(at point: CGPoint) {
        //TODO: implement
        print(point)
    }
}
