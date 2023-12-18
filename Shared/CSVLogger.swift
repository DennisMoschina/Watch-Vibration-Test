//
//  CSVWriter.swift
//  AirpodsTest
//
//  Created by Michael Küttner on 30.10.22.
//

import Foundation
import OSLog

class CSVLogger {
    private static let logger = Logger(subsystem: "edu.teco.moschina.Watch-Vibration-Test", category: "CSVLogger")
    
    var folderPath: String
    var fileName: String
    var header: [String]
    var file: FileHandle?
    var sensorFilepath: URL?
    
    init(folderPath: String, fileName: String, header: [String]) {
        Self.logger.debug("Sensorfilename_init: \(fileName)")
        Self.logger.debug("header_init: \(header)")
        self.folderPath = folderPath
        self.fileName = fileName
        self.header = header
        let sensorFilePath = folderPath + "/" + fileName + ".csv"
        self.sensorFilepath = URL(fileURLWithPath: sensorFilePath)
    }
    
    func writeLine(data: [Double]) {
        writeLine(data: data.map{String($0)})
    }
    
    func writeLine(data: [String]) {
        let line = data.joined(separator: ",") + "\n"
    
        self.file?.write(line.data(using: .utf8)!)
    }
    
    func startRecording() {
        // Create file
        let sensorFilePath = self.folderPath + "/" + self.fileName + ".csv"
        Self.logger.debug("Sensorfilepath: \(sensorFilePath)")
        FileManager.default.createFile(atPath: sensorFilePath, contents: nil, attributes: nil)
        self.file = try! FileHandle(forWritingTo: URL(string: sensorFilePath)!)
        let line = header.joined(separator: ",") + "\n"
        self.file?.write(line.data(using: .utf8)!)
    }
    
    func stopRecording() {
        try! self.file?.close()
    }
}
