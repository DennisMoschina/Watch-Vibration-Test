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
    
    let modelContainer: ModelContainer
    let modelContext: ModelContext
    
    var sqliteCommand: String {
        self.modelContext.sqliteCommand
    }
    
    private init() {
        self.modelContainer = try! ModelContainer(for: StudyEntry.self, configurations: ModelConfiguration())
        self.modelContext = ModelContext(self.modelContainer)
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
