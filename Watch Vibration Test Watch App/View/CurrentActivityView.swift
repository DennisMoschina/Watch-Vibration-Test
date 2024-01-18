//
//  NextActivityButton.swift
//  Watch Vibration Test Watch App
//
//  Created by Dennis Moschina on 21.12.23.
//

import SwiftUI

struct CurrentActivityView: View {
    @EnvironmentObject var studyViewModel: StudyViewModel
    
    @State var showConfirmNextAlert: Bool = false
    @State var showConfirmStopAlert: Bool = false
    
    @State private var previousDuration: Double = 0
    
    var body: some View {
        ZStack {
            VStack {
                Text(self.studyViewModel.studyActivity.string)
                    .font(.title2)
                    .scenePadding(.horizontal)
                
                Group {
                    if self.studyViewModel.studyActivity.duration != nil {
                        TimeDisplayView(timeInterval: self.studyViewModel.remainingTime)
                    } else {
                        Text("Take your time")
                    }
                }
                .foregroundStyle(.secondary)
            }
            
            Rectangle()
                .foregroundStyle(Color.clear)
            
            Circle()
                .trim(from: 0, to: self.studyViewModel.studyActivity.duration ?? 0 > 0 ? self.studyViewModel.remainingTime / self.studyViewModel.studyActivity.duration! : 0)
                .stroke(Color.orange, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .scenePadding(.horizontal)
                .animation(self.studyViewModel.remainingTime < self.previousDuration ? .linear(duration: 1) : nil, value: self.studyViewModel.remainingTime)
                .onChange(of: self.studyViewModel.remainingTime) { oldValue, newValue in
                    self.previousDuration = newValue
                }
            
            if self.studyViewModel.studyActivity.duration != nil {
                Circle()
                    .stroke(Color.orange.opacity(0.3), style: StrokeStyle(lineWidth: 3))
                    .scenePadding(.horizontal)
            }
        }
        .ignoresSafeArea(edges: .vertical)
        .toolbar {
            ToolbarItemGroup(placement: .bottomBar) {
                Text("")
                
                Button {
                    if self.studyViewModel.remainingTime > 0 {
                        self.showConfirmNextAlert.toggle()
                    } else {
                        self.studyViewModel.nextActivity()
                    }
                } label: {
                    Image(systemName: "forward.fill")
                }
            }
        }
        .alert("Next Activity", isPresented: self.$showConfirmNextAlert) {
            Button {
                self.studyViewModel.nextActivity()
            } label: {
                Text("Next Activity")
            }
            
            Button("Cancel", role: .cancel) { }
        }
        .alert("Stop Study", isPresented: self.$showConfirmStopAlert) {
            Button(role: .destructive) {
                self.studyViewModel.stopStudy()
            } label: {
                Text("Stop Study")
            }
            
            Button("Cancel", role: .cancel) { }
        }
    }
}

#Preview {
    StudyActivityManager.shared.start(process: StudyProcess(patternStartIndex: 0))
    
    return NavigationStack {
        CurrentActivityView()
            .environmentObject(StudyViewModel())
    }
}
