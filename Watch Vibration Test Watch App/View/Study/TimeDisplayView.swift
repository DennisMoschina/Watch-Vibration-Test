//
//  TimeDisplayView.swift
//  Watch Vibration Test Watch App
//
//  Created by Dennis Moschina on 06.01.24.
//

import SwiftUI

struct TimeDisplayView: View {
    var timeInterval: TimeInterval
    
    var formattedTime: String {
        if timeInterval >= 60 {
            let minutes = Int(timeInterval) / 60
            let seconds = Int(timeInterval) % 60
            return String(format: "%02d:%02d", minutes, seconds)
        } else {
            return String(format: "%2d s", Int(timeInterval))
        }
    }
    
    var body: some View {
        Text(formattedTime)
            .monospacedDigit()
    }
}

#Preview {
    TimeDisplayView(timeInterval: 100)
}
