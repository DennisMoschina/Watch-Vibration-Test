//
//  StudyActivityManager.swift
//  Watch Vibration Test
//
//  Created by Dennis Moschina on 14.12.23.
//

import Foundation

enum StudyActivity: CaseIterable, Equatable {
    static var allCases: [StudyActivity] {
        var cases: [StudyActivity] = [.none, .baseline, .moving, .recovery]
        cases.append(contentsOf: HapticPattern.defaults.map { StudyActivity.pattern(pattern: $0) })
        return cases
    }
    
    case none
    case baseline
    case pattern(pattern: HapticPattern)
    case moving
    case recovery
    
    var string: String {
        switch self {
        case .none: "None"
        case .baseline: "Baseline"
        case .pattern(pattern: let pattern):
            "Pattern: \(pattern.name)"
        case .moving: "Moving"
        case .recovery: "Recovery"
        }
    }
    
    var duration: TimeInterval? {
        switch self {
        case .none: nil
        case .baseline: 1200
        case .pattern(pattern: let pattern): pattern.automaticStop ? pattern.duration : nil
        case .moving: 60
        case .recovery: 60
        }
    }
}

class StudyActivityManager: ObservableObject {
    public static let shared = StudyActivityManager()
    
    @Published var activity: StudyActivity = .none
}
