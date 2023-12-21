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
    
    @State var showTimeoutAlert: Bool = false
    
    var body: some View {
        VStack {
            
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), content: {
                ForEach(StudyActivity.allCases, id: \.string) { activity in
                    Button {
                        self.activityManager.activity = activity
                    } label: {
                        Text(activity.string)
                            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 100)
                            .background {
                                self.activityManager.activity == activity
                                ? Color.accentColor
                                : Color(UIColor.systemGroupedBackground)
                            }
                    }
                    .buttonStyle(.plain)
                }
            })
            
            Spacer()
            
            Button {
                Task {
                    if await self.studyManager.stopStudy() {
                        self.activityManager.activity = .none
                        self.navigationViewModel.navigation.removeLast()
                    } else {
                        self.showTimeoutAlert.toggle()
                    }
                }
            } label: {
                Text("Stop Study")
                    .padding()
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(.red)
            .padding()
        }
        .alert("Connection timed out", isPresented: self.$showTimeoutAlert, actions: {
            Button("OK") { }
        })
        .alert("Failed to communicate with Watch", isPresented: self.$studyManager.communicationFailed, actions: {
            Button("OK") { }
        })
        .navigationTitle("Play Pattern")
        .navigationBarBackButtonHidden()
    }
}

#Preview {
    CurrentStudyView()
        .environmentObject(NavigationViewModel())
}
