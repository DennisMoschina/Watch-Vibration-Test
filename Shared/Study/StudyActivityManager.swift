//
//  StudyActivityManager.swift
//  Watch Vibration Test
//
//  Created by Dennis Moschina on 14.12.23.
//

import Foundation

enum StudyActivity: CaseIterable, Equatable, Hashable {
    static var allCases: [StudyActivity] {
        var cases: [StudyActivity] = [.none, .questionaire, .baseline, .moving, .recovery]
        cases.append(contentsOf: HapticPattern.defaults.map { StudyActivity.pattern(pattern: $0) })
        return cases
    }
    
    case none
    case questionaire
    case baseline
    case pattern(pattern: HapticPattern)
    case moving
    case recovery
    
    var string: String {
        switch self {
        case .none: "None"
        case .questionaire: "Questionaire"
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
        case .questionaire: nil
        case .baseline: 600
        case .pattern(pattern: let pattern): pattern.automaticStop ? pattern.duration : nil
        case .moving: 60
        case .recovery: 60
        }
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.string)
    }
}

struct StudyProcess {
    let activities: [StudyActivity]
    
    init(patternStartIndex: Int, patterns: [HapticPattern] = HapticPattern.defaults) {
        let hapticPatterns = patterns[patternStartIndex...] + patterns[..<patternStartIndex]
        self.activities = [.baseline, .questionaire] + hapticPatterns.flatMap({ pattern in
            [.moving, .recovery, .pattern(pattern: pattern), .questionaire]
        })
    }
}

class StudyActivityManager: ObservableObject {
    public static let shared = StudyActivityManager()
    
    @Published var activity: StudyActivity = .none {
        didSet {
            if let duration = self.activity.duration {
                self.activityEndTime = Date.now.addingTimeInterval(duration)
            } else {
                self.activityEndTime = nil
            }
        }
    }
    @Published var activityEndTime: Date?
    
    private(set) var process: StudyProcess?
    private var processIterator: IndexingIterator<[StudyActivity]>?
    
    func start(process: StudyProcess) {
        self.process = process
        self.processIterator = process.activities.makeIterator()
        self.activity = .none
    }
    
    func nextActivity() -> Bool {
        if let activity = self.processIterator?.next() {
            self.activity = activity
            return false
        } else {
            return true
        }
    }
    
    func activity(at index: Int) {
        guard var iterator = self.process?.activities.makeIterator() else {
            return //TODO: throw error
        }
        
        var activity: StudyActivity?
        for _ in 0..<(index + 1) {
            activity = iterator.next()
        }
        if let activity {
            self.activity = activity
            self.processIterator = iterator
        } else {
            //TODO: throw error
        }
    }
}
