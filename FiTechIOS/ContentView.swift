import SwiftUI

struct ContentView: View {
    
    @State private var viewModel = ViewModel()
    
    var body: some View {
        CameraView(
            image: $viewModel.currentFrame,
            poseObservation: viewModel.poseObservation,
            bodyObservation: viewModel.bodyObservation
        )
    }
}

#Preview {
    ContentView()
}
