//
//  HomeView.swift
//  Watch Vibration Test
//
//  Created by Dennis Moschina on 20.11.23.
//

import SwiftUI

struct HomeView: View {
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
        }
    }
}

#Preview {
    HomeView()
}
