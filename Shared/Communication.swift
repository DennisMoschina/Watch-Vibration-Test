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
    
    case sessionDirName = "session_dir"
    
    case activity = "activity"
    
    case study = "study"
}
