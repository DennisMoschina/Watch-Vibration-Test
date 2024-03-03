//
//  StudyEntriesManager.swift
//  RhythmSleep Study
//
//  Created by Dennis Moschina on 03.03.24.
//

import Foundation
import OSLog
import SwiftData

class StudyEntriesManager {
    private static let logger: Logger = Logger(subsystem: "edu.teco.moschina.WatchVibrationTest-Watch", category: "StudyEntriesManager")
    
    static let shared: StudyEntriesManager = StudyEntriesManager()
    
    private let watchCommunicator: WatchCommunicator = WatchCommunicator.shared
    
    private let fileHandler: FileHandler = FileHandler.default
    
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
            
            guard let url = self?.fileHandler.buildFilePath(uuid: studyEntry.id, fileName: fileName) else {
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
    }
    
    func refreshSessions() {
        guard let directories: [URL] = self.fileHandler.getStudyDirectories() else {
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
        guard directoryName.hasPrefix(FileHandler.STUDY_DIR_PREFIX) else { return nil }
        
        let uuidString = String(directoryName.dropFirst(FileHandler.STUDY_DIR_PREFIX.count))
            
        guard let uuid = UUID(uuidString: uuidString) else { return nil }
        guard let studyEntry = self.getSessionEntry(with: uuid) else {
            return nil
        }
        
        self.fileHandler.getFiles(in: directory)?.forEach { self.handleStudyFile(fileName: $0.lastPathComponent, url: $0, studyEntry: studyEntry) }
        
        return studyEntry
    }
    
    private func getSessionEntry(with id: UUID) -> StudyEntry? {
        if let studyEntry: StudyEntry = self.getExistingSessionEntry(with: id) {
            Self.logger.debug("found study entry with id: \(id)")
            return studyEntry
        }
        
        guard let folderURL = self.fileHandler.createPath(uuidString: id.uuidString) else {
            Self.logger.error("failed to create folder")
            return nil
        }
        
        let study = StudyEntry(detail: "", id: id, folder: folderURL, startDate: Date(), studyType: .none)
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
}
