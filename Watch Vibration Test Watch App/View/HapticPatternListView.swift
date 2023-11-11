//
//  HapticPatternListView.swift
//  Watch Vibration Test Watch App
//
//  Created by Dennis Moschina on 08.11.23.
//

import SwiftUI

struct HapticPatternListView: View {
    @EnvironmentObject var hapticViewModel: HapticViewModel
    
    var body: some View {
        ScrollView {
            ForEach(self.hapticViewModel.availablePatterns) { pattern in
                HapticPatternButton(pattern: pattern)
            }
            Button {
                
            } label: {
                Text("Create Pattern")
            }

        }
        .navigationTitle("Patterns")
    }
}

#Preview {
    NavigationStack {
        HapticPatternListView()
            .environmentObject(HapticViewModel(hapticManager: HapticManager()))
    }
}
