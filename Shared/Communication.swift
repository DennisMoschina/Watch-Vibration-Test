//
//  Communication.swift
//  Watch Vibration Test
//
//  Created by Dennis Moschina on 23.11.23.
//

import Foundation

enum MessageKeys: String {
    case playHaptic = "play_haptic"
    case playPattern = "play_pattern"
    case startStudy = "start_study"
    case stopStudy = "stop_study"
    
    case patterns = "haptic_patterns"
    
    case sessionUUID = "session_id"
    
    case activity = "activity"
    
    case study = "study"
}

enum FileNames: String {
    case heartRate = "heartRate"
    case detail = "detail"
    case label = "label"
}
