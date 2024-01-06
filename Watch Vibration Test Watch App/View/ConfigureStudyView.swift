//
//  ConfigureStudyView.swift
//  Watch Vibration Test Watch App
//
//  Created by Dennis Moschina on 21.12.23.
//

import SwiftUI

struct ConfigureStudyView: View {
    @EnvironmentObject var studyViewModel: StudyViewModel
    
    @State var studyDetail: String = ""
    
    var body: some View {
        VStack {
            TextField("Study detail", text: self.$studyDetail)
            
            Button {
                self.studyViewModel.startStudy(detail: self.studyDetail)
            } label: {
                Text("Start Study")
            }
            .tint(.green)
        }
        .navigationTitle("Study Config")
    }
}

#Preview {
    ConfigureStudyView()
        .environmentObject(StudyViewModel())
}
