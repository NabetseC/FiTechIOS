
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
