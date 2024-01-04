//
//  CurrentStudyView.swift
//  Watch Vibration Test Watch App
//
//  Created by Dennis Moschina on 21.12.23.
//

import SwiftUI

struct CurrentStudyView: View {
    @EnvironmentObject var studyViewModel: StudyViewModel
    @State var showEndStudyAlert: Bool = false
    
    @State var tab: Int = 1
    
    var body: some View {
        TabView(selection: self.$tab) {
            Button {
                self.showEndStudyAlert.toggle()
            } label: {
                Text("End Study")
            }
            .tint(.red)
            .tag(0)
            .alert("End Study", isPresented: self.$showEndStudyAlert) {
                Button("Cancel", role: .cancel) { }
                Button("End Study", role: .destructive) {
                    self.studyViewModel.stopStudy()
                }
            }
            
            CurrentActivityView()
                .tag(1)
        }
        .navigationBarBackButtonHidden()
    }
}

#Preview {
    CurrentStudyView()
        .environmentObject(StudyViewModel())
}
