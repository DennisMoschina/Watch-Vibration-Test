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
}
