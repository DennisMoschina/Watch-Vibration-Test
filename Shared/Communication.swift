//
//  Communication.swift
//  Watch Vibration Test
//
//  Created by Dennis Moschina on 23.11.23.
//

import Foundation

enum MessageKeys: String {
    case startStudy = "start_study"
    case stopStudy = "stop_study"
    
    case sessionUUID = "session_id"
    
    case activity = "activity"
    
    case type = "type"
}

enum FileNames: String {
    case heartRate = "heartRate"
    case detail = "detail"
    case label = "label"
    case clockRate = "clockRate"
}
