//
//  CurrentStudyView.swift
//  Watch Vibration Test
//
//  Created by Dennis Moschina on 17.12.23.
//

import SwiftUI

struct CurrentStudyView: View {
    @ObservedObject var activityManager: StudyActivityManager = StudyActivityManager.shared
    @ObservedObject var studyManager: StudyManager = StudyManager.shared
    
    @EnvironmentObject var navigationViewModel: NavigationViewModel
    
    var body: some View {
        Button {
            Task {
                if await self.studyManager.stopStudy() {
                    self.navigationViewModel.navigation.removeLast()
                }
            }
        } label: {
            Text("Stop Study")
        }
        .buttonStyle(.borderedProminent)
        .tint(.red)
    }
}

#Preview {
    CurrentStudyView()
        .environmentObject(NavigationViewModel())
}
