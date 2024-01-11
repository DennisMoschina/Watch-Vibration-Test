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
    
    @EnvironmentObject var navigationViewModel: NavigationViewModel
    @ObservedObject var studyManager: StudyManager = StudyManager.shared
    
    @State var studyDetail: String = ""
    @State var showStudyDetailAlert: Bool = false
    
    var body: some View {
        Group {
            if self.studies.isEmpty {
                Text("No Studies recorded")
                    .font(.title)
            } else {
                List {
                    ForEach(self.studies) { study in
                        HStack {
                            Text(study.detail)
                            Spacer()
                            Text(study.startDate.formatted())
                                .foregroundStyle(.secondary)
                        }
                    }
                    .onDelete(perform: self.deleteEntries(at:))
                }
            }
        }
        .navigationTitle("Studies")
        .alert("Study detail", isPresented: self.$showStudyDetailAlert) {
            TextField("Study detail", text: self.$studyDetail)
            Button("Start Study") {
                Task {
                    if await self.studyManager.startStudy(detail: self.studyDetail) {
                        DispatchQueue.main.async {
                            self.navigationViewModel.navigation.append(Navigation.studyRunning)
                        }
                    }
                }
            }
            
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Please enter details about this session.")
        }
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
        }
        catch {
            print("Error deleting file: \(error)")
        }
    }
}

#Preview {
    StudiesListView()
        .environmentObject(NavigationViewModel())
}
