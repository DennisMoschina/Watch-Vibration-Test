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
    
    @State var showActivitiesSheet: Bool = false
    
    var body: some View {
        TabView(selection: self.$tab) {
            HStack {
                Button {
                    self.showEndStudyAlert.toggle()
                } label: {
                    Image(systemName: "xmark")
                        .font(.title)
                }
                .tint(.red)
                .alert("End Study", isPresented: self.$showEndStudyAlert) {
                    Button("Cancel", role: .cancel) { }
                    Button("End Study", role: .destructive) {
                        self.studyViewModel.stopStudy()
                    }
                }
                
                Button {
                    self.showActivitiesSheet.toggle()
                } label: {
                    Image(systemName: "list.bullet")
                        .font(.title)
                }
                .sheet(isPresented: self.$showActivitiesSheet, onDismiss: {
                    self.tab = 1
                }, content: {
                    ChangeActivityView()
                })
            }
            .tag(0)
            
            CurrentActivityView()
                .tag(1)
        }
        .navigationBarBackButtonHidden()
    }
}

#Preview {
    StudyActivityManager.shared.start(process: StudyProcess(patternStartIndex: 0))
    
    return NavigationStack {
        CurrentStudyView()
            .environmentObject(StudyViewModel())
    }
}
