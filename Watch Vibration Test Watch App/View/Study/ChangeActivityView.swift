//
//  ChangeActivityView.swift
//  Watch Vibration Test Watch App
//
//  Created by Dennis Moschina on 21.12.23.
//

import SwiftUI

struct ChangeActivityView: View {
    @Environment(\.dismiss) var dismiss
    
    @ObservedObject var activityManager: StudyActivityManager = StudyActivityManager.shared
    
    @State var showConfirmAlert: Bool = false
    @State var activityIndex: Int?
    
    var body: some View {
        List(selection: self.$activityIndex) {
            ForEach(Array(self.activityManager.process?.activities.enumerated() ?? [].enumerated()), id: \.offset) { (index, activity) in
                Text(activity.string)
            }
        }
        .onChange(of: self.activityIndex) { _, newValue in
            if newValue != nil {
                self.showConfirmAlert.toggle()
            }
        }
        .alert("Confirm activity change", isPresented: self.$showConfirmAlert) {
            Button("Cancel", role: .cancel) { }
            Button("OK") {
                if let activityIndex {
                    self.activityManager.activity(at: activityIndex)
                    self.dismiss()
                }
            }
        }
    }
}

#Preview {
    StudyActivityManager.shared.start(process: StudyProcess(patternStartIndex: 0))
    
    return ChangeActivityView()
}
