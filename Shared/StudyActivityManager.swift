//
//  StudyActivityManager.swift
//  Watch Vibration Test
//
//  Created by Dennis Moschina on 14.12.23.
//

import Foundation

enum StudyActivity: CaseIterable {
    static var allCases: [StudyActivity] {
        var cases: [StudyActivity] = [.none, .baseline, .moving]
        cases.append(contentsOf: HapticPattern.defaults.map { StudyActivity.pattern(pattern: $0) })
        return cases
    }
    
    case none
    case baseline
    case pattern(pattern: HapticPattern)
    case moving
    
    var string: String {
        switch self {
        case .none: "None"
        case .baseline: "Baseline"
        case .pattern(pattern: let pattern):
            pattern.name
        case .moving: "Moving"
        }
    }
}

class StudyActivityManager: ObservableObject {
    public static let shared = StudyActivityManager()
    
    @Published var activity: StudyActivity = .none
}
