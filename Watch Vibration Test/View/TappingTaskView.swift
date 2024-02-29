//
//  TappingTaskView.swift
//  Watch Vibration Test
//
//  Created by Dennis Moschina on 28.02.24.
//

import SwiftUI

struct TappingTaskView: View {
    @EnvironmentObject var studyViewModel: StudyViewModel
    
    var body: some View {
        Rectangle()
            .onTapGesture(coordinateSpace: .global, perform: self.studyViewModel.registerTappingTaskTap(at:))
    }
}

#Preview {
    TappingTaskView()
        .environmentObject(StudyViewModel())
}
