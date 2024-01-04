//
//  NavigationViewModel.swift
//  Watch Vibration Test Watch App
//
//  Created by Dennis Moschina on 21.12.23.
//

import Foundation
import SwiftUI
import Combine

enum Navigation: Hashable {
    case configureStudy
    case studyRunning
}

class StudyViewModel: ObservableObject {
    @Published var navigation: NavigationPath = NavigationPath()
    @Published private(set) var study: StudyLogger?
    @Published var studyActivity: StudyActivity {
        didSet {
            self.activityManager.activity = self.studyActivity
        }
    }
    
    @Published var remainingTime: TimeInterval = 0
    
    private var studyManager = SessionManager.shared
    private var activityManager = StudyActivityManager.shared
    private var phoneCommunicator = PhoneCommunicator.shared
    
    private var cancellables: [AnyCancellable?] = []
    
    private var remainingTimeTimer: Timer?
    
    init() {
        self.studyActivity = StudyActivityManager.shared.activity
        self.study = self.studyManager.study
        
        self.cancellables.append(contentsOf: [
            self.activityManager.$activity.sink(receiveValue: { activity in
                if self.studyActivity != activity {
                    self.studyActivity = activity
                }
            }),
            self.studyManager.$study.sink(receiveValue: { study in
                if self.study?.id != study?.id, study != nil {
                    self.navigation.append(Navigation.studyRunning)
                }
                self.study = study
            }),
            self.activityManager.$activityEndTime.sink(receiveValue: { date in
                if let date {
                    guard date > Date.now else {
                        self.remainingTime = 0
                        return
                    }
                    
                    self.remainingTime = Date.now.distance(to: date)

                    self.remainingTimeTimer?.invalidate()
                    self.remainingTimeTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { timer in
                        if date <= Date.now {
                            timer.invalidate()
                            self.remainingTime = 0
                            switch self.studyActivity {
                            case .pattern(pattern: _), .none:
                                break
                            default:
                                HapticManager().play(haptic: .notification)
                            }
                        } else {
                            self.remainingTime = Date.now.distance(to: date)
                        }
                    })
                } else {
                    self.remainingTimeTimer?.invalidate()
                    self.remainingTime = 0
                }
            })
        ])
    }
    
    func startStudy(detail: String) {
        self.activityManager.start(process: StudyProcess(patternStartIndex: 0))
        _ = self.studyManager.startStudy(detail: detail)
    }
    
    func stopStudy() {
        if let study = self.studyManager.stopStudy() {
            self.phoneCommunicator.transfer(study: study)
        }
        self.navigation.removeLast(self.navigation.count)
        self.remainingTime = 0
        self.remainingTimeTimer?.invalidate()
    }
    
    func nextActivity() {
        if self.activityManager.nextActivity() {
            self.stopStudy()
        }
    }
}
