//
//  HapticPatternButton.swift
//  Watch Vibration Test Watch App
//
//  Created by Dennis Moschina on 08.11.23.
//

import SwiftUI

struct HapticPatternButton: View {
    @EnvironmentObject var hapticViewModel: HapticViewModel
    
    var pattern: HapticPattern
    
    var body: some View {
        Button(action: {
            self.hapticViewModel.play(pattern: self.pattern)
        }, label: {
            VStack(alignment: .leading) {
                HStack {
                    Text(self.pattern.name)
                        .font(.headline)
                        .foregroundStyle(.white)
                    Spacer()
                }
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(self.pattern.haptics) { haptic in
                            Image(systemName: haptic.icon)
                        }
                    }
                }
                HStack {
                    Text("\(self.pattern.frequency)BPM")
                    
                    Spacer()
                    
                    Text(self.pattern.automaticStop
                         ? "\(self.pattern.duration, specifier: "%.0f")s"
                         : "Offen"
                    )
                }
                .foregroundStyle(.secondary)
            }
        })
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        HapticPatternButton(pattern: HapticPattern(name: "Test Pattern", haptics: Haptic.defaults, frequency: 60))
            .environmentObject(HapticViewModel(hapticManager: HapticManager()))
    }
}
