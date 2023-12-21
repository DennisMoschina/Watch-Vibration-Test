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
    
    private var studyManager = SessionManager.shared
    private var activityManager = StudyActivityManager.shared
    private var phoneCommunicator = PhoneCommunicator.shared
    
    private var cancellables: [AnyCancellable?] = []
    
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
                self.study = study
                if let study {
                    self.navigation.append(Navigation.studyRunning)
                }
            })
        ])
    }
    
    func startStudy(detail: String) {
        _ = self.studyManager.startStudy(detail: detail)
    }
    
    func stopStudy() {
        if let study = self.studyManager.stopStudy() {
            self.phoneCommunicator.transfer(study: study)
        }
        self.navigation.removeLast(self.navigation.count)
    }
}
