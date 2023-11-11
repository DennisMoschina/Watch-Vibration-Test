//
//  EditPatternView.swift
//  Watch Vibration Test Watch App
//
//  Created by Dennis Moschina on 08.11.23.
//

import SwiftUI

struct EditPatternView: View {
    @EnvironmentObject var hapticViewModel: HapticViewModel
    
    @State var pattern: HapticPattern
    
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
    EditPatternView(pattern: HapticPattern(name: "Test", haptics: Haptic.defaults, frequency: 60))
        .previewDevice("Apple Watch Series 9 (45mm)")
    
    EditPatternView(pattern: HapticPattern(name: "Test", haptics: Haptic.defaults, frequency: 60))
        .previewDevice("Apple Watch Series 9 (41mm)")
}
