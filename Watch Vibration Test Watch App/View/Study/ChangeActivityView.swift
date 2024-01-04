//
//  ChangeActivityView.swift
//  Watch Vibration Test Watch App
//
//  Created by Dennis Moschina on 21.12.23.
//

import SwiftUI

struct ChangeActivityView: View {
    @ObservedObject var activityManager: StudyActivityManager = StudyActivityManager.shared
    
    var body: some View {
        List(StudyActivity.allCases, id: \.string) { activity in
            Text(activity.string)
        }
    }
}

#Preview {
    ChangeActivityView()
}
