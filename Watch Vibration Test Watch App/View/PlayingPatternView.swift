//
//  PlayingPatternView.swift
//  Watch Vibration Test Watch App
//
//  Created by Dennis Moschina on 13.11.23.
//

import SwiftUI
import SwiftData

struct PlayingPatternView: View {
    @EnvironmentObject var hapticViewModel: HapticViewModel
    
    var pattern: HapticPattern
    
    var body: some View {
        HStack {
            Button {
                self.hapticViewModel.stop()
            } label: {
                Image(systemName: "xmark")
                    .font(.title)
            }
            .tint(.red)
        }
        .navigationTitle(self.pattern.name)
        .navigationBarBackButtonHidden()
    }
}

#Preview {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: HapticPattern.self, configurations: config)
        let example = HapticPattern(name: "Test", haptics: Haptic.defaults, frequency: 60)

        return PlayingPatternView(pattern: example)
            .environmentObject(HapticViewModel(hapticManager: HapticManager()))
            .modelContainer(container)
    } catch {
        fatalError("Failed to create model container.")
    }
}
