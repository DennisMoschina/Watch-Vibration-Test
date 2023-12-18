//
//  HapticPatternListView.swift
//  Watch Vibration Test Watch App
//
//  Created by Dennis Moschina on 08.11.23.
//

import SwiftUI
import SwiftData

enum PatternNavigation: Hashable {
    case play(pattern: HapticPattern)
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self)
    }
}

struct HapticPatternListView: View {
    @EnvironmentObject var hapticViewModel: HapticViewModel
    var patterns: [HapticPattern] = HapticPattern.defaults
    
    var body: some View {
        List {
            ForEach(self.patterns) { pattern in
                HapticPatternButton(pattern: pattern)
            }
        }
        .listStyle(.carousel)
        .navigationTitle("Patterns")
        .navigationDestination(for: PatternNavigation.self) { navigation in
            switch navigation {
            case .play(pattern: let pattern):
                PlayingPatternView(pattern: pattern)
            }
        }
    }
}

#Preview {
    HapticPatternListView()
        .environmentObject(HapticViewModel(hapticManager: HapticManager()))
}
