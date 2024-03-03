//
//  FileManager.swift
//  RhythmSleep Study
//
//  Created by Dennis Moschina on 03.03.24.
//

import Foundation
import OSLog

class FileHandler {
    static let `default`: FileHandler = FileHandler()
    
    private static let logger: Logger = Logger(subsystem: "edu.teco.moschina.WatchVibrationTest-Watch", category: "FileHandler")
    
    static let STUDY_DIR_PREFIX: String = "session_"
    
    private var fileManager: FileManager = FileManager.default
    
    func createPath(uuidString: String) -> URL? {
        do {
            let dir = self.getBaseURL()
            
            let folder = Self.STUDY_DIR_PREFIX + uuidString
            let folderURL = dir.appendingPathComponent(folder)
            try self.fileManager.createDirectory(at: folderURL, withIntermediateDirectories: true)
            return folderURL
        } catch {
            Self.logger.error("failed to create folder \(error)")
        }
        return nil
    }
    
    func getBaseURL() -> URL {
        return self.fileManager.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first!
    }
    
    func buildFilePath(uuid: UUID, fileName: String) -> URL? {
        self.getBaseURL().appending(path: "\(Self.STUDY_DIR_PREFIX)\(uuid.uuidString)").appending(path: fileName)
    }
    
    func getStudyDirectories() -> [URL]? {
        do {
            let contents = try self.fileManager.contentsOfDirectory(at: self.getBaseURL(), includingPropertiesForKeys: [.isDirectoryKey], options: .skipsHiddenFiles)
            
            return contents.filter { url in
                let resourceValues = try? url.resourceValues(forKeys: [.isDirectoryKey])
                return resourceValues?.isDirectory ?? false
            }
        } catch {
            Self.logger.error("\(error)")
        }
        return nil
    }
    
    func getFiles(in directory: URL) -> [URL]? {
        do {
            return try FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: [.isRegularFileKey], options: .skipsHiddenFiles).filter(\.isFileURL)
        } catch {
            Self.logger.error("\(error)")
            return nil
        }
    }
    
    func createFile(in directory: URL, fileName: String, content: String) {
        FileManager.default.createFile(atPath: directory.appending(path: fileName).path(), contents: content.data(using: .utf8))
    }
}
