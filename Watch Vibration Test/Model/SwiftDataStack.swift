//
//  SwiftDataStack.swift
//  Watch Vibration Test
//
//  Created by Dennis Moschina on 14.12.23.
//

import Foundation
import SwiftData

class SwiftDataStack {
    public static let shared: SwiftDataStack = SwiftDataStack()
    
    internal static let preview: SwiftDataStack = SwiftDataStack.buildPreview()
    
    let modelContainer: ModelContainer
    let modelContext: ModelContext
    
    var sqliteCommand: String {
        self.modelContext.sqliteCommand
    }
    
    private init(storedInMemoryOnly: Bool = false) {
        self.modelContainer = try! ModelContainer(for: StudyEntry.self, configurations: ModelConfiguration(isStoredInMemoryOnly: storedInMemoryOnly))
        self.modelContext = ModelContext(self.modelContainer)
    }
    
    private static func buildPreview() -> SwiftDataStack {
        let stack = SwiftDataStack(storedInMemoryOnly: true)
        
        [
            StudyEntry(detail: "Study 1", id: UUID(), folder: URL(fileURLWithPath: ""), startDate: Date().addingTimeInterval(-3600), studyType: .none),
            StudyEntry(detail: "Study 2", id: UUID(), folder: URL(fileURLWithPath: ""), startDate: Date().addingTimeInterval(2 * -3600), studyType: .constantRhythm),
            StudyEntry(detail: "Study 3", id: UUID(), folder: URL(fileURLWithPath: ""), startDate: Date().addingTimeInterval(3 * -3600), studyType: .regulatedRhythm),
            StudyEntry(detail: "Study 4", id: UUID(), folder: URL(fileURLWithPath: ""), startDate: Date().addingTimeInterval(4 * -3600), studyType: .none),
            StudyEntry(detail: "Study 5", id: UUID(), folder: URL(fileURLWithPath: ""), startDate: Date().addingTimeInterval(5 * -3600), studyType: .constantRhythm),
            StudyEntry(detail: "Study 6", id: UUID(), folder: URL(fileURLWithPath: ""), startDate: Date().addingTimeInterval(6 * -3600), studyType: .regulatedRhythm),
            StudyEntry(detail: "Study 7", id: UUID(), folder: URL(fileURLWithPath: ""), startDate: Date().addingTimeInterval(7 * -3600), studyType: .none),
            StudyEntry(detail: "Study 8", id: UUID(), folder: URL(fileURLWithPath: ""), startDate: Date().addingTimeInterval(8 * -3600), studyType: .constantRhythm),
            StudyEntry(detail: "Study 9", id: UUID(), folder: URL(fileURLWithPath: ""), startDate: Date().addingTimeInterval(9 * -3600), studyType: .regulatedRhythm),
            StudyEntry(detail: "Study 10", id: UUID(), folder: URL(fileURLWithPath: ""), startDate: Date().addingTimeInterval(10 * -3600), studyType: .none),
            StudyEntry(detail: "Study 11", id: UUID(), folder: URL(fileURLWithPath: ""), startDate: Date().addingTimeInterval(11 * -3600), studyType: .constantRhythm),
            StudyEntry(detail: "Study 12", id: UUID(), folder: URL(fileURLWithPath: ""), startDate: Date().addingTimeInterval(12 * -3600), studyType: .regulatedRhythm),
            StudyEntry(detail: "Study 13", id: UUID(), folder: URL(fileURLWithPath: ""), startDate: Date().addingTimeInterval(13 * -3600), studyType: .none),
            StudyEntry(detail: "Study 14", id: UUID(), folder: URL(fileURLWithPath: ""), startDate: Date().addingTimeInterval(14 * -3600), studyType: .constantRhythm),
            StudyEntry(detail: "Study 15", id: UUID(), folder: URL(fileURLWithPath: ""), startDate: Date().addingTimeInterval(15 * -3600), studyType: .regulatedRhythm),
            StudyEntry(detail: "Study 16", id: UUID(), folder: URL(fileURLWithPath: ""), startDate: Date().addingTimeInterval(16 * -3600), studyType: .none),
            StudyEntry(detail: "Study 17", id: UUID(), folder: URL(fileURLWithPath: ""), startDate: Date().addingTimeInterval(17 * -3600), studyType: .constantRhythm),
            StudyEntry(detail: "Study 18", id: UUID(), folder: URL(fileURLWithPath: ""), startDate: Date().addingTimeInterval(18 * -3600), studyType: .regulatedRhythm),
            StudyEntry(detail: "Study 19", id: UUID(), folder: URL(fileURLWithPath: ""), startDate: Date().addingTimeInterval(19 * -3600), studyType: .none),
            StudyEntry(detail: "Study 20", id: UUID(), folder: URL(fileURLWithPath: ""), startDate: Date().addingTimeInterval(20 * -3600), studyType: .constantRhythm),
            StudyEntry(detail: "Study 21", id: UUID(), folder: URL(fileURLWithPath: ""), startDate: Date().addingTimeInterval(21 * -3600), studyType: .regulatedRhythm)
        ].forEach { stack.modelContext.insert($0) }
        
        return stack
    }
}

extension ModelContext {
    var sqliteCommand: String {
        if let url = container.configurations.first?.url.path(percentEncoded: false) {
            "sqlite3 \"\(url)\""
        } else {
            "No SQLite database found."
        }
    }
}
