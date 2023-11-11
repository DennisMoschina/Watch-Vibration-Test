//
//  HomeView.swift
//  Watch Vibration Test Watch App
//
//  Created by Dennis Moschina on 08.11.23.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationStack {
            NavigationLink("Play Single Haptic", destination: PlaySingularHapticListView())
            NavigationLink("Play Patterns", destination: HapticPatternListView())
                .navigationTitle("Haptic Test")
        }
        .environmentObject(HapticViewModel(hapticManager: HapticManager()))
    }
}

#Preview {
    HomeView()
}
