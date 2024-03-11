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

enum StudyError: Error {
    case fileError
    case communicationError
}

class StudyManager {
    private static let STUDY_DIR_PREFIX: String = "session_"
    
    private static let logger: Logger = Logger(subsystem: "edu.teco.moschina.WatchVibrationTest-Watch", category: "StudyManager")

    public static let shared: StudyManager = .init()
    
    private let watchCommunicator = WatchCommunicator.shared
    
    var study: StudyEntry?
    var communicationFailed: Bool = false
    
    private var cancellables: [AnyCancellable] = []
    
    private var fileHandler: FileHandler = FileHandler.default
    
    var studyStartedSubject: PassthroughSubject<Void, Error> = PassthroughSubject()
    var studyStoppedSubject: PassthroughSubject<StudyEntry, Error> = PassthroughSubject()
    
    private init() {
        StudyActivityManager.shared.$activity.sink { activity in
            Task {
                if !(await self.watchCommunicator.sendActivity(activity)) {
                    Self.logger.info("notifying clients about failed activity send")
                    DispatchQueue.main.async {
                        self.communicationFailed.toggle()
                    }
                }
            }
        }.store(in: &self.cancellables)
        self.watchCommunicator.receivedStopSubject.sink { _ in
            self.tearDownStudy()
        }.store(in: &self.cancellables)
    }
    
    func startStudy(detail: String, type: StudyType = .none) async -> Bool {
        if let id = await self.watchCommunicator.startStudy(type: type) {
            guard let folderPath = self.fileHandler.createPath(uuidString: id.uuidString) else {
                Self.logger.error("failed to create folderPath")
                self.studyStartedSubject.send(completion: Subscribers.Completion.failure(StudyError.fileError))
                return false
            }
            defer { self.studyStartedSubject.send() }
            self.study = StudyEntry(detail: detail, id: id, folder: folderPath, startDate: Date(), studyType: type)
            SwiftDataStack.shared.modelContext.insert(self.study!)
            self.fileHandler.createFile(in: folderPath, fileName: "\(FileNames.detail.rawValue).txt", content: detail)
            return true
        } else {
            self.studyStartedSubject.send(completion: Subscribers.Completion.failure(StudyError.communicationError))
            return false
        }
    }
    
    func stopStudy() async -> Bool {
        let stopped = await self.watchCommunicator.stopStudy()
        if stopped {
            self.tearDownStudy()
        } else {
            self.studyStoppedSubject.send(completion: Subscribers.Completion.failure(StudyError.communicationError))
        }
        return stopped
    }
    
    private func tearDownStudy() {
        //TODO: implement
        
        guard let study else { return }
        self.studyStoppedSubject.send(study)
        
        self.study = nil
    }
    
    func registerTappingTaskTap(at point: CGPoint) {
        //TODO: implement
        print(point)
    }
}
