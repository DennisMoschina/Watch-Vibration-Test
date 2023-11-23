//
//  ContentView.swift
//  Watch Vibration Test
//
//  Created by Dennis Moschina on 07.11.23.
//

import SwiftUI
import SwiftData

struct PatternList: View {
    var patterns: [HapticPattern] = []
    
    var body: some View {
        List {
            ForEach(self.patterns) { pattern in
                VStack {
                    Text(pattern.name)
                    
                    HStack {
                        ForEach(pattern.haptics) { haptic in
                            Image(systemName: haptic.icon)
                        }
                    }
                }
            }
        }
        .navigationTitle("Patterns")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
    }
}

#Preview {
    PatternList()
}
