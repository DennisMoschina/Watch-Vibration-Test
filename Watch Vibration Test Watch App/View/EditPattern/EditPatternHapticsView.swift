//
//  EditPatternHapticsView.swift
//  Watch Vibration Test Watch App
//
//  Created by Dennis Moschina on 14.11.23.
//

import SwiftUI

struct EditPatternHapticsView: View {
    @Bindable var pattern: HapticPattern
    
    var body: some View {
        VStack {
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
                        Image(systemName: "delete.backward.fill")
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
    EditPatternHapticsView(pattern: HapticPattern(name: "Test", haptics: [], frequency: 60))
}
