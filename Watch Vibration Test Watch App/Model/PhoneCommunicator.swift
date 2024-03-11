//
//  PhoneCommunicator.swift
//  Watch Vibration Test Watch App
//
//  Created by Dennis Moschina on 19.11.23.
//

import Foundation
import WatchConnectivity
import OSLog
import Combine


class PhoneCommunicator: NSObject, WCSessionDelegate {
    private static let logger: Logger = Logger(subsystem: "edu.teco.moschina.Watch-Vibration-Test.watchkitapp", category: "WatchCommunicator")

    static let shared: PhoneCommunicator = PhoneCommunicator()
    
    private let wcSession: WCSession
    
    var hapticManager: HapticManager?
    
    private override init() {
        self.wcSession = WCSession.default
        super.init()
        self.wcSession.delegate = self
        self.wcSession.activate()
    }
    
    func transfer(study: StudyLogger) {
        self.transferStudyFiles(for: study.folderURL)
    }
    
    func stop(study: StudyLogger) {
        self.transfer(study: study)
        self.wcSession.sendMessage([MessageKeys.stopStudy.rawValue : true], replyHandler: nil)
    }
    
    private func transferStudyFiles(for dirURL: URL) {
        let sessionID: UUID = self.findUUID(in: dirURL.lastPathComponent) ?? UUID()
        
        let fileManager = FileManager.default
        do {
            let urls: [URL] = try fileManager.contentsOfDirectory(atPath: dirURL.path()).compactMap { URL(string: $0) }
            
            for url in urls {
                Self.logger.debug("sending file \(url) to phone")
                let fileURL = dirURL.appending(path: url.path())
                self.wcSession.transferFile(fileURL, metadata: [MessageKeys.sessionUUID.rawValue : sessionID.uuidString])
            }
        } catch {
            Self.logger.error("failed to get urls for files")
        }
    }
    
    private func findUUID(in string: String) -> UUID? {
        let pattern = "[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}"
        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        
        let nsString = string as NSString
        let matches = regex?.matches(in: string, options: [], range: NSRange(location: 0, length: nsString.length))
        
        guard let uuidString = matches?.first.map({ nsString.substring(with: $0.range) }) else {
            Self.logger.error("failed to find uuid in \(string)")
            return nil
        }
        
        return UUID(uuidString: uuidString)
    }


    //MARK: Delegate Methods
    
    internal func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        Self.logger.info("activation completed: \(activationState.rawValue)")
        return
    }
    
    internal func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        Self.logger.debug("received: \(message)")
        if let stopStudy = message[MessageKeys.stopStudy.rawValue] as? Bool, stopStudy {
            if let studyFolderURL: URL = SessionManager.shared.stopStudy()?.folderURL {
                self.transferStudyFiles(for: studyFolderURL)
            }
        }
    }
    
    internal func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        Self.logger.debug("received with reply expected: \(message)")
        if let startStudy = message[MessageKeys.startStudy.rawValue] as? Bool, startStudy {
            if let studyType: StudyType = (message[MessageKeys.type.rawValue] as? String).flatMap({ StudyType(rawValue: $0) }) {
                let pattern: HapticPattern = switch studyType {
                case .none:
                    HapticPattern(name: "Silence", duration: 60 * 20)
                case .regulatedRhythm:
                    HapticPattern(name: "Regulated", haptics: [.start, .start, .failure], clock: HeartRateClock(heartRateSensor: HeartRateSensor.shared), duration: 60 * 20)
                case .constantRhythm:
                    HapticPattern(name: "Constant", haptics: [.start, .start, .failure], clock: FrequencyClock(frequency: 60), duration: 60 * 20)
                }
                StudyActivityManager.shared.start(process: StudyProcess(activities: [.baseline, .questionaire, .pattern(pattern: pattern), .questionaire]))
                if let id = SessionManager.shared.startStudy() {
                    replyHandler([MessageKeys.startStudy.rawValue : id.uuidString])
                } else {
                    replyHandler([MessageKeys.startStudy.rawValue : false])
                }
            }
        } else if let stopStudy = message[MessageKeys.stopStudy.rawValue] as? Bool, stopStudy {
            Self.logger.info("stopping Study")
            if let url: URL = SessionManager.shared.stopStudy()?.folderURL {
                self.transferStudyFiles(for: url)
            }
            replyHandler([MessageKeys.stopStudy.rawValue : true])
        } else if let activityString = message[MessageKeys.activity.rawValue] as? String {
            Self.logger.debug("received new activity \(activityString)")
            guard let activity: StudyActivity = StudyActivity.allCases.first(where: { $0.string == activityString }) else {
                Self.logger.error("\(activityString) is not a valid activity")
                replyHandler([MessageKeys.activity.rawValue : StudyActivityManager.shared.activity.string])
                return
            }
            DispatchQueue.main.sync {
                StudyActivityManager.shared.activity = activity
            }
            replyHandler([MessageKeys.activity.rawValue : StudyActivityManager.shared.activity.string])
        } else {
            replyHandler(["unknown key" : ""])
        }
    }
}
                        
