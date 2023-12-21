//
//  CurrentStudyView.swift
//  Watch Vibration Test Watch App
//
//  Created by Dennis Moschina on 21.12.23.
//

import SwiftUI

struct CurrentStudyView: View {
    @ObservedObject var studyViewModel: StudyViewModel
    @State var showEndStudyAlert: Bool = false
    
    var body: some View {
        VStack {
            Text(self.studyViewModel.study?.detail ?? "error")
            
            Button {
                self.showEndStudyAlert.toggle()
            } label: {
                Text("End Study")
            }
            .tint(.red)
            .alert("End Study", isPresented: self.$showEndStudyAlert) {
                Button("Cancel", role: .cancel) { }
                Button("End Study", role: .destructive) {
                    self.studyViewModel.stopStudy()
                }
            }

        }
        .navigationBarBackButtonHidden()
    }
}

#Preview {
    CurrentStudyView(studyViewModel: StudyViewModel())
}
