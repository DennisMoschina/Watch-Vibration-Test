//
//  NavigationViewModel.swift
//  Watch Vibration Test
//
//  Created by Dennis Moschina on 17.12.23.
//

import Foundation
import SwiftUI

enum Navigation: Hashable {
    case studyRunning
}

class NavigationViewModel: ObservableObject {
    @Published var navigation: NavigationPath = NavigationPath()
    
    init() {
        StudyManager.shared.onStudyStarted.append { [weak self] in
            self?.navigation.append(Navigation.studyRunning)
        }
        
        StudyManager.shared.onStudyStopped.append { [weak self] in
            self?.navigation.removeLast()
        }
    }
}
