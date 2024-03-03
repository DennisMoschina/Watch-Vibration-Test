//
//  StudyType.swift
//  Watch Vibration Test
//
//  Created by Dennis Moschina on 28.02.24.
//

import Foundation

enum StudyType: String, CaseIterable, Identifiable, Codable {
    var id: String { self.rawValue }
    
    case none = "None"
    case regulatedRhythm = "Regulated Rhythm"
    case constantRhythm = "Constant Rhythm"
    
    var name: String {
        self.rawValue
    }
}
