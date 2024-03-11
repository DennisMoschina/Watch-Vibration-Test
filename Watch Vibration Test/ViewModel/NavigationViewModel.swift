//
//  NavigationViewModel.swift
//  Watch Vibration Test
//
//  Created by Dennis Moschina on 17.12.23.
//

import Foundation
import SwiftUI
import Combine

enum Navigation: Hashable {
    case configureStudy
    case studyRunning
}

class NavigationViewModel: ObservableObject {
    @Published var navigation: NavigationPath = NavigationPath()
    
    private var cancellables: [AnyCancellable] = []
    
    init() {
        StudyManager.shared.studyStartedSubject.receive(on: DispatchQueue.main).sink(receiveCompletion: { completion in
            //TODO: implement
        }, receiveValue: { [weak self] in
            self?.navigation.append(Navigation.studyRunning)
        }).store(in: &self.cancellables)
        
        StudyManager.shared.studyStoppedSubject.receive(on: DispatchQueue.main).sink(receiveCompletion: { completion in
            //TODO: implement
        }, receiveValue: { [weak self] _ in
            guard let self else { return }
            self.navigation.removeLast(self.navigation.count)
        }).store(in: &self.cancellables)
    }
}
