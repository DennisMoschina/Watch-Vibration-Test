//
//  ConfigureStudyView.swift
//  Watch Vibration Test
//
//  Created by Dennis Moschina on 28.02.24.
//

import SwiftUI

struct ConfigureStudyView: View {
    @State var studyID: String = ""
    @State var studyType: StudyType = .none
    
    var body: some View {
        List {
            TextField("Study ID", text: self.$studyID)
            
            Picker(selection: self.$studyType) {
                ForEach(StudyType.allCases) { type in
                    Text(type.name)
                }
            } label: {
                Text("Study Type")
            }

        }
    }
}

#Preview {
    ConfigureStudyView()
}
