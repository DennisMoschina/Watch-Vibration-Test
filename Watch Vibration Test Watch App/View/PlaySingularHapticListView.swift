//
//  PlaySingularHapticListView.swift
//  Watch Vibration Test Watch App
//
//  Created by Dennis Moschina on 07.11.23.
//

import SwiftUI

struct PlaySingularHapticListView: View {
    @EnvironmentObject var hapticViewModel: HapticViewModel
    
    var body: some View {
        List(self.hapticViewModel.availableHaptics) { haptic in
            Button {
                self.hapticViewModel.play(haptic: haptic)
            } label: {
                Label(haptic.name, systemImage: haptic.icon)
            }
        }
        .navigationTitle("Haptic")
    }
}

#Preview {
    PlaySingularHapticListView()
        .environmentObject(HapticViewModel(hapticManager: HapticManager()))
}
