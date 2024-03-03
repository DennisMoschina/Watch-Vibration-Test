//
//  HomeView.swift
//  RhythmSleep Study
//
//  Created by Dennis Moschina on 02.03.24.
//

import SwiftUI

struct HomeView: View {
    @State var showStudyConfiguration: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                StudiesListView()
                
                Button {
                    self.showStudyConfiguration.toggle()
                } label: {
                    Image(systemName: "plus")
                        .font(.title)
                        .padding()
                }
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.circle)
                .shadow(radius: 10)
            }
            .sheet(isPresented: self.$showStudyConfiguration, content: {
                NavigationStack {
                    ConfigureStudyView()
                }
            })
        }
    }
}

#Preview {
    HomeView()
        .environment(\.modelContext, SwiftDataStack.preview.modelContext)
}
