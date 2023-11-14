//
//  HomeView.swift
//  Watch Vibration Test Watch App
//
//  Created by Dennis Moschina on 08.11.23.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var hapticViewModel: HapticViewModel
    
    var body: some View {
        NavigationStack(path: self.$hapticViewModel.navigation) {
            VStack {
                NavigationLink(value: AppNavigation.playSingleList) {
                    Text("Play Single Haptic")
                }
                NavigationLink(value: AppNavigation.patternList) {
                    Text("Play Pattern")
                }
            }
            .navigationDestination(for: AppNavigation.self, destination: { navigation in
                switch navigation {
                case .playSingleList:
                    PlaySingularHapticListView()
                case .patternList:
                    HapticPatternListView()
                case .playPattern(let pattern):
                    PlayingPatternView(pattern: pattern)
                case .editPattern(pattern: let pattern):
                    EditPatternView(pattern: pattern)
                }
            })
            .navigationTitle("Haptic Test")
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(HapticViewModel(hapticManager: HapticManager()))
}
