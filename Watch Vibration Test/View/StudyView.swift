//
//  StartStudyView.swift
//  Watch Vibration Test
//
//  Created by Dennis Moschina on 28.02.24.
//

import SwiftUI

struct StudyView: View {
    @EnvironmentObject var studyViewModel: StudyViewModel
    
    var body: some View {
        TappingTaskView()
            .ignoresSafeArea()
            .navigationBarBackButtonHidden()
            .gesture(RotateGesture(minimumAngleDelta: Angle(degrees: 180))
                .onEnded { _ in
                    self.studyViewModel.requestStop()
                })
            .alert("Stop Study", isPresented: self.$studyViewModel.showStopAlert) {
                Button("Stop Study") {
                    self.studyViewModel.stopStudy()
                }
                
                Button("Cancel", role: .cancel) { }
            }
    }
}

#Preview {
    NavigationStack {
        StudyView()
            .environmentObject(StudyViewModel())
    }
}
