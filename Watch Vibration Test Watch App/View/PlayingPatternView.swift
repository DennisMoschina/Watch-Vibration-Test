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
    PlayingPatternView(pattern: HapticPattern.defaults.first!)
        .environmentObject(HapticViewModel(hapticManager: HapticManager()))
}
