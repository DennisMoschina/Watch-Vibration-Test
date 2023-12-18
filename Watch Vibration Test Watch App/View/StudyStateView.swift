//
//  StudyStateView.swift
//  Watch Vibration Test Watch App
//
//  Created by Dennis Moschina on 18.12.23.
//

import SwiftUI

struct StudyStateView: View {
    @ObservedObject var studyManager = SessionManager.shared
    @ObservedObject var studyStateManager = StudyActivityManager.shared
    
    init() {
        PhoneCommunicator.shared.hapticManager = HapticManager()
    }
    
    var body: some View {
        if !(studyManager.study?.running ?? false) {
            Text("No Study running")
        } else {
            Text(self.studyStateManager.activity.string)
        }
    }
}

#Preview {
    StudyStateView()
}
