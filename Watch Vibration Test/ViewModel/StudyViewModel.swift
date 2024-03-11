//
//  StudyViewModel.swift
//  RhythmSleep Study
//
//  Created by Dennis Moschina on 03.03.24.
//

import Foundation

class StudyViewModel: ObservableObject {
    var studyManager: StudyManager = StudyManager.shared
    
    @Published var showStopAlert: Bool = false
    
    @Published var timeout: Bool = false
    
    @Published var processing: Bool = false
    
    func registerTappingTaskTap(at point: CGPoint) {
        self.studyManager.registerTappingTaskTap(at: point)
    }
    
    func requestStop() {
        self.showStopAlert.toggle()
    }
    
    func startStudy(detail: String, type: StudyType) {
        self.processing = true
        Task {
            defer {
                DispatchQueue.main.async { self.processing = false }
            }
            guard await self.studyManager.startStudy(detail: detail, type: type) else {
                DispatchQueue.main.async { self.timeout = true }
                return
            }
        }
    }
    
    func stopStudy() {
        self.processing = true
        Task {
            defer {
                DispatchQueue.main.async { self.processing = false }
            }
            guard await self.studyManager.stopStudy() else {
                DispatchQueue.main.async { self.timeout = true }
                return
            }
        }
    }
}
