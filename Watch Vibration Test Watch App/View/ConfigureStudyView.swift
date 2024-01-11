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
    @State var patternStartIndex: Int = 0
    
    var body: some View {
        VStack {
            TextField("Study detail", text: self.$studyDetail)
            
            Stepper(value: self.$patternStartIndex, in:  ClosedRange(uncheckedBounds: (0, HapticPattern.defaults.count - 1))) {
                Text("#\(self.patternStartIndex)")
                    .monospacedDigit()
                    .font(.body)
            }
            
            Button {
                self.studyViewModel.startStudy(detail: self.studyDetail, patternStartIndex: self.patternStartIndex)
            } label: {
                Text("Start Study")
                    .font(.title3)
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
