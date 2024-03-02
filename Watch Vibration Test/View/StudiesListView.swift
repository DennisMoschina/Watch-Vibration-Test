//
//  StartStudyView.swift
//  Watch Vibration Test
//
//  Created by Dennis Moschina on 14.12.23.
//

import SwiftUI
import SwiftData

struct StudiesListView: View {
    @Environment(\.modelContext) var modelContext
    @Query var studies: [StudyEntry]
    
    @ObservedObject var studyManager: StudyManager = StudyManager.shared
    
    var body: some View {
        Group {
            if self.studies.isEmpty {
                Text("No Studies recorded")
                    .font(.title)
            } else {
                List {
                    Section {
                        ForEach(self.studies) { study in
                            HStack {
                                Text(study.detail)
                                Spacer()
                                Text(study.startDate.formatted())
                                    .foregroundStyle(.secondary)
                            }
                        }
                    } footer: {
                        Text("\(self.studies.count) Studies")
                            .font(.body)
                            .frame(minWidth: 0, maxWidth: .infinity)
                    }
                }
            }
        }
        .navigationTitle("Studies")
    }
    
    func deleteEntries(at offsets: IndexSet) {
        let entries = self.studies
        
        for index in offsets {
            
            let entry = entries[index]
            self.deleteSessionData(dir: entry.folder)
            self.delete(entry: entry)
        }
    }
    
    func delete(entry: StudyEntry) {
        self.modelContext.delete(entry)
    }
    
    func deleteSessionData(dir: URL) {
        let fileManager = FileManager.default
        
        do {
            try fileManager.removeItem(at: dir)
        } catch {
            print("Error deleting file: \(error)")
        }
    }
}

#Preview {
    NavigationStack {
        StudiesListView()
    }
}
