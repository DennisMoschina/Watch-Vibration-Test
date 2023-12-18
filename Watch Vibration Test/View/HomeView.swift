//
//  HomeView.swift
//  Watch Vibration Test
//
//  Created by Dennis Moschina on 20.11.23.
//

import SwiftUI

struct HomeView: View {
    @ObservedObject var studiesNavigationViewModel = NavigationViewModel()
    
    var body: some View {
        TabView {
            NavigationStack {
                PatternList()
            }
            .tabItem {
                Label("Pattern", systemImage: "play.fill")
            }
            
            NavigationStack {
                HapticList()
            }
            .tabItem {
                Label("Haptic", systemImage: "cursorarrow.rays")
            }
            
            NavigationStack(path: self.$studiesNavigationViewModel.navigation){
                StudiesListView()
                    .environmentObject(self.studiesNavigationViewModel)
            }
            .tabItem {
                Label("Study", systemImage: "waveform.path.ecg.rectangle")
            }
        }
    }
}

#Preview {
    HomeView()
}
