//
//  Haptic.swift
//  Watch Vibration Test Watch App
//
//  Created by Dennis Moschina on 07.11.23.
//

import Foundation
import WatchKit

struct Haptic: Identifiable {
    var id: String { self.name }
    
    let name: String
    let hapticType: WKHapticType?
    
    static let defaults: [Haptic] = [
        Haptic(name: "None", hapticType: nil),
        Haptic(name: "Notification", hapticType: .notification),
        Haptic(name: "DirectionUp", hapticType: .directionUp),
        Haptic(name: "DirectionDown", hapticType: .directionUp),
        Haptic(name: "Success", hapticType: .success),
        Haptic(name: "Failure", hapticType: .failure),
        Haptic(name: "Retry", hapticType: .retry),
        Haptic(name: "Start", hapticType: .start),
        Haptic(name: "Stop", hapticType: .stop),
        Haptic(name: "Click", hapticType: .click),
        Haptic(name: "NavigationGenereic", hapticType: .navigationGenericManeuver),
        Haptic(name: "NavigationLeft", hapticType: .navigationLeftTurn),
        Haptic(name: "NavigationRight", hapticType: .navigationRightTurn),
        Haptic(name: "UnderwaterCritical", hapticType: .underwaterDepthCriticalPrompt),
        Haptic(name: "Underwater", hapticType: .underwaterDepthPrompt)
    ]
}
