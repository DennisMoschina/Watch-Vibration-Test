//
//  HomeView.swift
//  Watch Vibration Test Watch App
//
//  Created by Dennis Moschina on 08.11.23.
//

import SwiftUI
import SwiftData

enum MainNavigation: Hashable {
    case singularHapticList
    case patternList
}

struct HomeView: View {
    @EnvironmentObject var hapticViewModel: HapticViewModel
    
    var body: some View {
        NavigationStack(path: self.$hapticViewModel.navigation) {
            VStack {
                NavigationLink(value: MainNavigation.singularHapticList) {
                    Text("Play Single Haptic")
                }
                NavigationLink(value: MainNavigation.patternList) {
                    Text("Play Pattern")
                }
            }
            .navigationDestination(for: MainNavigation.self, destination: { navigation in
                switch navigation {
                case .singularHapticList:
                    PlaySingularHapticListView()
                case .patternList:
                    HapticPatternListView()
                }
            })
            .navigationTitle("Haptic Test")
        }
    }
}

#Preview {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: HapticPattern.self, configurations: config)
        return HomeView()
            .environmentObject(HapticViewModel(hapticManager: HapticManager()))
            .modelContainer(container)
    } catch {
        fatalError("Failed to create model container.")
    }
}
