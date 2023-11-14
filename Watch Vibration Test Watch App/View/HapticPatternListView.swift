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
    case edit(pattern: HapticPattern)
}

struct HapticPatternListView: View {
    @Environment(\.modelContext) var modelContext
    @EnvironmentObject var hapticViewModel: HapticViewModel
    @Query var patterns: [HapticPattern]
    
    var body: some View {
        List {
            ForEach(self.patterns) { pattern in
                HapticPatternButton(pattern: pattern)
            }
            .onDelete(perform: self.deletePatterns)
            
            Button {
                let pattern = HapticPattern()
                self.modelContext.insert(pattern)
                self.hapticViewModel.navigation.append(PatternNavigation.edit(pattern: pattern))
            } label: {
                Text("Create Pattern")
            }
            .buttonStyle(.plain)
        }
        .listStyle(.carousel)
        .navigationTitle("Patterns")
        .navigationDestination(for: PatternNavigation.self) { navigation in
            switch navigation {
            case .play(pattern: let pattern):
                PlayingPatternView(pattern: pattern)
            case .edit(pattern: let pattern):
                EditPatternView(pattern: pattern)
            }
        }
    }
    
    func deletePatterns(_ indexSet: IndexSet) {
        for index in indexSet {
            let pattern = self.patterns[index]
            self.modelContext.delete(pattern)
        }
    }
}

#Preview {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: HapticPattern.self, configurations: config)
        return HapticPatternListView()
            .environmentObject(HapticViewModel(hapticManager: HapticManager()))
            .modelContainer(container)
    } catch {
        fatalError("Failed to create model container.")
    }
}
