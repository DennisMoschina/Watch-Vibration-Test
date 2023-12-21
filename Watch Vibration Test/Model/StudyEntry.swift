//
//  StudyEntry.swift
//  Watch Vibration Test
//
//  Created by Dennis Moschina on 14.12.23.
//

import Foundation
import SwiftData

@Model
class StudyEntry {
    var detail: String
    var id: UUID
    var folder: URL
    
    var startDate: Date
    
    init(detail: String, id: UUID, folder: URL, startDate: Date) {
        self.detail = detail
        self.id = id
        self.folder = folder
        self.startDate = startDate
    }
}
