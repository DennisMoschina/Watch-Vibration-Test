//
//  ConfigureStudyView.swift
//  Watch Vibration Test
//
//  Created by Dennis Moschina on 28.02.24.
//

import SwiftUI

struct ConfigureStudyView: View {
    @State var studyID: String = ""
    @State var studyType: StudyType = .none
    
    @EnvironmentObject var studyViewModel: StudyViewModel
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Form {
                Section {
                    TextField("Study ID", text: self.$studyID)
                    
                    Picker(selection: self.$studyType) {
                        ForEach(StudyType.allCases) { type in
                            Text(type.name)
                                .tag(type)
                        }
                    } label: {
                        Text("Study Type")
                    }
                }
            }
            .scrollDisabled(true)
            
            Button {
                self.studyViewModel.startStudy(detail: self.studyID, type: self.studyType)
            } label: {
                ZStack {
                    if self.studyViewModel.processing {
                        ProgressView()
                    }
                    Text("Start Study")
                        .padding()
                }
            }
            .disabled(self.studyViewModel.processing)
            .buttonStyle(.borderedProminent)
        }
        .navigationTitle("Configure Study")
    }
}

#Preview {
    NavigationStack {
        ConfigureStudyView()
            .environmentObject(StudyViewModel())
    }
}
