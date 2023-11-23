//
//  Haptic.swift
//  Watch Vibration Test Watch App
//
//  Created by Dennis Moschina on 07.11.23.
//

import Foundation

#if os(watchOS)
import WatchKit
#endif

struct Haptic: Identifiable, Codable {
#if os(watchOS)
    typealias HapticType = WKHapticType
#else
    typealias HapticType = Int
#endif
    
    var id: String { self.name }
    
    let name: String
    
    let hapticType: HapticType?
    
    var icon: String
    
    init(name: String, hapticType: HapticType?, icon: String) {
        self.name = name
        self.hapticType = hapticType
        self.icon = icon
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.icon = try container.decode(String.self, forKey: .icon)
        // Decode the raw value of the hapticType enum
        let rawValue = try container.decode(Int.self, forKey: .hapticType)
        // Convert the raw value to the enum case, or nil if not found
        #if os(watchOS)
        self.hapticType = WKHapticType(rawValue: rawValue)
        #else
        self.hapticType = rawValue
        #endif
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(icon, forKey: .icon)
        // Encode the raw value of the hapticType enum, or nil if not present
        #if os(watchOS)
        try container.encode(hapticType?.rawValue, forKey: .hapticType)
        #else
        try container.encode(hapticType, forKey: .hapticType)
        #endif
    }
    
    // Coding keys for the properties
    enum CodingKeys: String, CodingKey {
        case name
        case hapticType
        case icon
    }
    
    #if os(watchOS)
    static let defaults: [Haptic] = [
        Haptic(name: "None", hapticType: nil, icon: "speaker"),
        Haptic(name: "Notification", hapticType: .notification, icon: "app.badge"),
        Haptic(name: "DirectionUp", hapticType: .directionUp, icon: "arrow.up"),
        Haptic(name: "DirectionDown", hapticType: .directionDown, icon: "arrow.down"),
        Haptic(name: "Success", hapticType: .success, icon: "checkmark"),
        Haptic(name: "Failure", hapticType: .failure, icon: "xmark"),
        Haptic(name: "Retry", hapticType: .retry, icon: "arrow.clockwise"),
        Haptic(name: "Start", hapticType: .start, icon: "play"),
        Haptic(name: "Stop", hapticType: .stop, icon: "stop"),
        Haptic(name: "Click", hapticType: .click, icon: "hand.tap"),
        Haptic(name: "NavigationGenereic", hapticType: .navigationGenericManeuver, icon: "location.north.fill"),
        Haptic(name: "NavigationLeft", hapticType: .navigationLeftTurn, icon: "arrow.turn.up.left"),
        Haptic(name: "NavigationRight", hapticType: .navigationRightTurn, icon: "arrow.turn.up.right"),
        Haptic(name: "UnderwaterCritical", hapticType: .underwaterDepthCriticalPrompt, icon: "water.waves.and.arrow.down.trianglebadge.exclamationmark"),
        Haptic(name: "Underwater", hapticType: .underwaterDepthPrompt, icon: "water.waves.and.arrow.down")
    ]
    #else
    static let defaults: [Haptic] = [
        Haptic(name: "None", hapticType: nil, icon: "speaker"),
        Haptic(name: "Notification", hapticType: 0, icon: "app.badge"),
        Haptic(name: "DirectionUp", hapticType: 1, icon: "arrow.up"),
        Haptic(name: "DirectionDown", hapticType: 2, icon: "arrow.down"),
        Haptic(name: "Success", hapticType: 3, icon: "checkmark"),
        Haptic(name: "Failure", hapticType: 4, icon: "xmark"),
        Haptic(name: "Retry", hapticType: 5, icon: "arrow.clockwise"),
        Haptic(name: "Start", hapticType: 6, icon: "play"),
        Haptic(name: "Stop", hapticType: 7, icon: "stop"),
        Haptic(name: "Click", hapticType: 8, icon: "hand.tap"),
        Haptic(name: "NavigationGenereic", hapticType: 11, icon: "location.north.fill"),
        Haptic(name: "NavigationLeft", hapticType: 9, icon: "arrow.turn.up.left"),
        Haptic(name: "NavigationRight", hapticType: 10, icon: "arrow.turn.up.right"),
        Haptic(name: "UnderwaterCritical", hapticType: 13, icon: "water.waves.and.arrow.down.trianglebadge.exclamationmark"),
        Haptic(name: "Underwater", hapticType: 12, icon: "water.waves.and.arrow.down")
    ]
    #endif
}
