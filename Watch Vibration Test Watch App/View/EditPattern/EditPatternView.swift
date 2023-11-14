//
//  EditPatternView.swift
//  Watch Vibration Test Watch App
//
//  Created by Dennis Moschina on 08.11.23.
//

import SwiftUI
import SwiftData

enum EditPatternNavigation: Hashable {
    case name(pattern: HapticPattern)
    case haptics(pattern: HapticPattern)
    case frequency(pattern: HapticPattern)
}

struct EditPatternView: View {
    @Bindable var pattern: HapticPattern
    
    var body: some View {
        List {
            TextField(text: self.$pattern.name) {
                Text("Name")
            }
            
            VStack {
                Text("Haptics")
                    .foregroundStyle(.secondary)
                
                HStack {
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(self.pattern.haptics) { haptic in
                                Image(systemName: haptic.icon)
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .foregroundStyle(Color.secondary)
                                    )
                            }
                        }
                    }
                    NavigationLink(value: EditPatternNavigation.haptics(pattern: self.pattern)) {
                        Image(systemName: "pencil.circle.fill")
                            .symbolRenderingMode(.hierarchical)
                            .font(.title2)
                    }
                    .buttonStyle(.plain)
                }
            }
            
            Stepper(value: self.$pattern.frequency) {
                Text("\(self.pattern.frequency)Hz")
            }
            
        }
        .navigationDestination(for: EditPatternNavigation.self) { navigation in
            switch navigation {
            case .haptics(pattern: let pattern):
                EditPatternHapticsView(pattern: pattern)
            default:
                Text("unknown Destination")
            }
        }
    }
}

#Preview {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: HapticPattern.self, configurations: config)
        let example = HapticPattern(name: "Test", haptics: Haptic.defaults, frequency: 60)
        return EditPatternView(pattern: example)
            .modelContainer(container)
    } catch {
        fatalError("Failed to create model container.")
    }
}
