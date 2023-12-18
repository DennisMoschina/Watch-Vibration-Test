//
//  StudyManager.swift
//  Watch Vibration Test
//
//  Created by Dennis Moschina on 14.12.23.
//

import Foundation
import SwiftData
import OSLog

class StudyManager: ObservableObject {
    private static let logger: Logger = Logger(subsystem: "edu.teco.moschina.WatchVibrationTest-Watch", category: "StudyManager")

    public static let shared: StudyManager = .init()
    
    private let watchCommunicator = WatchCommunicator.shared
    
    @Published var study: StudyEntry?
    
    private init() {
        self.watchCommunicator.onFileReceive.append { [weak self] file in
            guard let dirName = file.metadata?[MessageKeys.sessionDirName.rawValue] as? String else {
                Self.logger.error("failed to get dir from metadata")
                return
            }
            let fileName: String = file.fileURL.lastPathComponent
            guard let url = self?.getBaseURL().appending(path: dirName).appending(path: fileName) else {
                Self.logger.error("failed to create url to save file")
                return
            }
            do {
                try FileManager.default.moveItem(at: file.fileURL, to: url)
            } catch {
                Self.logger.error("failed to move file \(error)")
            }
        }
    }
    
    func startStudy(detail: String = "") async -> Bool {
        if let id = await self.watchCommunicator.startStudy() {
            guard let folderPath = self.createPath(uuidString: id.uuidString) else {
                Self.logger.error("failed to create folderPath")
                return false
            }
            DispatchQueue.main.sync {
                self.study = StudyEntry(detail: detail, id: id, folder: folderPath)
            }
            SwiftDataStack.shared.modelContext.insert(self.study!)
            return true
        } else {
            return false
        }
    }
    
    func stopStudy() async -> Bool {
        return await self.watchCommunicator.stopStudy()
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