//
//  EditPatternView.swift
//  Watch Vibration Test Watch App
//
//  Created by Dennis Moschina on 08.11.23.
//

import SwiftUI
import SwiftData

struct EditPatternView: View {
    @Bindable var pattern: HapticPattern
    
    var body: some View {
        VStack {
            TextField(text: .constant("")) {
                Text("Name")
            }
            
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
                    
                    Button {
                        self.pattern.haptics.removeLast()
                    } label: {
                        Image(systemName: "delete.left")
                    }
                    .tint(.red)

                }
            }
            
            Divider()
            
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 30))]) {
                    ForEach(Haptic.defaults) { haptic in
                        Button {
                            self.pattern.haptics.append(haptic)
                        } label: {
                            Image(systemName: haptic.icon)
                        }
                    }
                }
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
