//
//  StudyStateView.swift
//  Watch Vibration Test Watch App
//
//  Created by Dennis Moschina on 18.12.23.
//

import SwiftUI

struct StartStudyView: View {
    @EnvironmentObject var studyViewModel: StudyViewModel
    
    @ObservedObject var studyManager = SessionManager.shared
    
    init() {
        let hapticManager = HapticManager()
        PhoneCommunicator.shared.hapticManager = hapticManager
        self.studyManager.hapticManager = hapticManager
    }
    
    var body: some View {
        NavigationStack(path: self.$studyViewModel.navigation) {
            Button {
                self.studyViewModel.navigation.append(Navigation.configureStudy)
            } label: {
                Text("Start Study")
            }
            .tint(.green)
            .navigationDestination(for: Navigation.self) { navigation in
                switch navigation {
                case .configureStudy:
                    ConfigureStudyView()
                case .studyRunning:
                    CurrentStudyView()
                }
            }
        }
    }
}

#Preview {
    StartStudyView()
        .environmentObject(StudyViewModel())
}
