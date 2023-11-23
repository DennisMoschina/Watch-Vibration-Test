//
//  HapticList.swift
//  Watch Vibration Test
//
//  Created by Dennis Moschina on 19.11.23.
//

import SwiftUI

struct HapticList: View {
    var body: some View {
        List(Haptic.defaults) { haptic in
            Button {
                WatchCommunicator.shared.play(haptic: haptic)
            } label: {
                Label(haptic.name, systemImage: haptic.icon)
            }
        }
        .navigationTitle("Play Haptic")
    }
}

#Preview {
    HapticList()
}
