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

class StudyManager: ObservableObject {
    private static let STUDY_DIR_PREFIX: String = "session_"
    
    private static let logger: Logger = Logger(subsystem: "edu.teco.moschina.WatchVibrationTest-Watch", category: "StudyManager")

    public static let shared: StudyManager = .init()
    
    private let watchCommunicator = WatchCommunicator.shared
    
    @Published var study: StudyEntry?
    @Published var communicationFailed: Bool = false
    
    private var cancellables: [AnyCancellable?] = []
    
    private init() {
        self.watchCommunicator.onFileReceive.append { [weak self] file in
            guard let uuidString = file.metadata?[MessageKeys.sessionUUID.rawValue] as? String else {
                Self.logger.error("failed to uuid string from metadata")
                return
            }
            guard let sessionUUID = UUID(uuidString: uuidString) else {
                Self.logger.error("\(uuidString) is not a valid uuid")
                return
            }
            let fileName: String = file.fileURL.lastPathComponent
            
            guard let studyEntry: StudyEntry = self?.getSessionEntry(with: sessionUUID) else {
                Self.logger.error("failed to get study entry")
                return
            }
            
            guard let url = self?.getBaseURL().appending(path: "\(Self.STUDY_DIR_PREFIX)\(studyEntry.id.uuidString)").appending(path: fileName) else {
                Self.logger.error("failed to create url to save file")
                return
            }
            do {
                try FileManager.default.moveItem(at: file.fileURL, to: url)
            } catch {
                Self.logger.error("failed to move file \(error)")
            }

            self?.handleStudyFile(fileName: fileName, url: url, studyEntry: studyEntry)
        }
        
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
    
    func startStudy(detail: String = "") async -> Bool {
        if let id = await self.watchCommunicator.startStudy() {
            guard let folderPath = self.createPath(uuidString: id.uuidString) else {
                Self.logger.error("failed to create folderPath")
                return false
            }
            DispatchQueue.main.sync {
                self.study = StudyEntry(detail: detail, id: id, folder: folderPath, startDate: Date())
            }
            SwiftDataStack.shared.modelContext.insert(self.study!)
            FileManager.default.createFile(atPath: folderPath.appending(path: "\(FileNames.detail.rawValue).txt").path(), contents: detail.data(using: .utf8))
            return true
        } else {
            return false
        }
    }
    
    func stopStudy() async -> Bool {
        return await self.watchCommunicator.stopStudy()
    }
    
    func refreshSessions() {
        let baseURL: URL = self.getBaseURL()
        let fileManager: FileManager = FileManager.default
        
        guard let directories: [URL] = {
            do {
                let contents = try fileManager.contentsOfDirectory(at: baseURL, includingPropertiesForKeys: [.isDirectoryKey], options: .skipsHiddenFiles)
                
                return contents.filter { url in
                    let resourceValues = try? url.resourceValues(forKeys: [.isDirectoryKey])
                    return resourceValues?.isDirectory ?? false
                }
            } catch {
                Self.logger.error("\(error)")
            }
            return nil
        }() else {
            return
        }
        
        for directory in directories {
            if let entry = self.createStudyEntry(from: directory) {
                SwiftDataStack.shared.modelContext.insert(entry)
            }
        }
    }
    
    private func createStudyEntry(from directory: URL) -> StudyEntry? {
        let directoryName: String = directory.lastPathComponent
        guard directoryName.hasPrefix(Self.STUDY_DIR_PREFIX) else { return nil }
        
        let uuidString = String(directoryName.dropFirst(Self.STUDY_DIR_PREFIX.count))
            
        guard let uuid = UUID(uuidString: uuidString) else { return nil }
        guard let studyEntry = self.getSessionEntry(with: uuid) else {
            return nil
        }
        
        do {
            let contents: [URL] = try FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: [.isRegularFileKey], options: .skipsHiddenFiles)
            contents.filter(\.isFileURL).forEach { self.handleStudyFile(fileName: $0.lastPathComponent, url: $0, studyEntry: studyEntry) }
        } catch {
            Self.logger.error("\(error)")
        }
        
        return studyEntry
    }
    
    private func handleStudyFile(fileName: String, url: URL, studyEntry: StudyEntry) {
        switch fileName.split(separator: ".").first ?? "" {
        case FileNames.detail.rawValue:
            do {
                let detail = try String(contentsOf: url)
                studyEntry.detail = detail
            } catch {
                Self.logger.error("failed to read detail file \(error)")
            }
        case FileNames.label.rawValue:
            do {
                let label = try String(contentsOf: url)
                let lines = label.split(separator: "\n")
                if let firstLine = lines.first {
                    let columns = firstLine.split(separator: ",")
                    if columns.count > 1 {
                        if let startTime = Double(columns[0]) {
                            studyEntry.startDate = Date(timeIntervalSince1970: startTime)
                        }
                    }
                }
            } catch {
                Self.logger.error("failed to read label file \(error)")
            }
        default:
            break
        }
    }
    
    private func getSessionEntry(with id: UUID) -> StudyEntry? {        
        if let studyEntry: StudyEntry = self.getExistingSessionEntry(with: id) {
            Self.logger.debug("found study entry with id: \(id)")
            return studyEntry
        }
        
        guard let folderURL = self.createPath(uuidString: id.uuidString) else {
            Self.logger.error("failed to create folder")
            return nil
        }
        
        let study = StudyEntry(detail: "", id: id, folder: folderURL, startDate: Date())
        SwiftDataStack.shared.modelContext.insert(study)
        return study
    }
    
    private func getExistingSessionEntry(with id: UUID) -> StudyEntry? {
        let predicate = #Predicate<StudyEntry> { entry in
            entry.id == id
        }
        let fetchDescriptor: FetchDescriptor<StudyEntry> = FetchDescriptor(predicate: predicate)
        do {
            let entries: [StudyEntry] = try SwiftDataStack.shared.modelContext.fetch(fetchDescriptor)
            return entries.first
        } catch {
            Self.logger.error("failed to fetch entries with error \(error)")
            return nil
        }
    }
    
    private func createPath(uuidString: String) -> URL? {
        do {
            let dir = self.getBaseURL()
            
            let folder = "session_" + uuidString
            let folderURL = dir.appendingPathComponent(folder)
            try FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: true)
            return folderURL
        } catch let e {
            Self.logger.error("failed to create folder \(e)")
        }
        return nil
    }
    
    private func getBaseURL() -> URL {
        return FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first!
    }
}
