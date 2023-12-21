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

    func send(patterns: [HapticPattern]) {
        do {
            try self.wcSession.updateApplicationContext([MessageKeys.patterns.rawValue : patterns])
        } catch {
            Self.logger.error("failed to send patterns with error \(error)")
        }
    }
    
    func transfer(study: StudyLogger) {
        //TODO: implement
    }
    
    private func transferStudyFiles(for dirURL: URL) {
        let sessionDirName: String = dirURL.lastPathComponent
        
        let fileManager = FileManager.default
        do {
            let urls: [URL] = try fileManager.contentsOfDirectory(atPath: dirURL.path()).compactMap { URL(string: $0) }
            
            for url in urls {
                let fileURL = dirURL.appending(path: url.path())
                self.wcSession.transferFile(fileURL, metadata: [MessageKeys.sessionDirName.rawValue : sessionDirName])
            }
        } catch {
            Self.logger.error("failed to get urls for files")
        }
    }

    //MARK: Delegate Methods
    
    internal func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        Self.logger.info("activation completed: \(activationState.rawValue)")
        return
    }
    
    internal func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        Self.logger.debug("received: \(message)")
        if let hapticData = message[MessageKeys.playHaptic.rawValue] as? Data {
            let decoder = JSONDecoder()
            if let haptic: Haptic = try? decoder.decode(Haptic.self, from: hapticData) {
                self.hapticManager?.play(haptic: haptic)
            } else {
                Self.logger.error("failed to decode haptic")
            }
        }
        if let stopStudy = message[MessageKeys.stopStudy.rawValue] as? Bool, stopStudy {
            if let studyFolderURL: URL = SessionManager.shared.stopStudy()?.folderURL {
                self.transferStudyFiles(for: studyFolderURL)
            }
        }
    }
    
    internal func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        Self.logger.debug("received with reply expected: \(message)")
        if let startStudy = message[MessageKeys.startStudy.rawValue] as? Bool, startStudy {
            if let id = SessionManager.shared.startStudy() {
                replyHandler([MessageKeys.startStudy.rawValue : id.uuidString])
            } else {
                replyHandler([MessageKeys.startStudy.rawValue : false])
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
