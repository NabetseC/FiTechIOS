//
//  ContentView.swift
//  Swift1
//
//  Created by esteban cubides on 6/5/25.
//

import SwiftUI

struct ContentView: View {
    
    @State private var viewModel = ViewModel()
    
    var body: some View {
        CameraView(image: $viewModel.currentFrame)
    }
}

#Preview {
    ContentView()
}
