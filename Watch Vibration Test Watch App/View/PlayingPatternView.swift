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
    @ObservedObject var heartRateSensor: HeartRateSensor = HeartRateSensor.shared
    
    var pattern: HapticPattern
    
    var body: some View {
        VStack {
            Text("\(self.heartRateSensor.heartRate, specifier: "%.0f")bpm")
            
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
