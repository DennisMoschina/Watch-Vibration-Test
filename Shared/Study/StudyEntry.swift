//
//  StudyEntry.swift
//  Watch Vibration Test
//
//  Created by Dennis Moschina on 14.12.23.
//

import Foundation
import SwiftData

@Model
class StudyEntry: Codable {
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
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.detail = try container.decode(String.self, forKey: .detail)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.folder = try container.decode(URL.self, forKey: .folder)
        self.startDate = try container.decode(Date.self, forKey: .startDate)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.detail, forKey: .detail)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.folder, forKey: .folder)
        try container.encode(self.startDate, forKey: .startDate)
    }
    
    private enum CodingKeys: String, CodingKey {
        case detail
        case id
        case folder
        case startDate
    }
}
