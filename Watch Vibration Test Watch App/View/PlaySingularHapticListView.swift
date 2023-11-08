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
                Text(haptic.name)
            }
        }
    }
}

#Preview {
    PlaySingularHapticListView()
        .environmentObject(HapticViewModel(hapticManager: HapticManager()))
}
