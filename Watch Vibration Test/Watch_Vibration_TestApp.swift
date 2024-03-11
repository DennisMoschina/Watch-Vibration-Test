//
//  Watch_Vibration_TestApp.swift
//  Watch Vibration Test
//
//  Created by Dennis Moschina on 07.11.23.
//

import SwiftUI

@main
struct Watch_Vibration_TestApp: App {
    init() {
        _ = WatchCommunicator.shared
        _ = StudyEntriesManager.shared
        _ = StudyManager.shared
    }
    
    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(NavigationViewModel())
                .modelContainer(SwiftDataStack.shared.modelContainer)
        }
    }
}
