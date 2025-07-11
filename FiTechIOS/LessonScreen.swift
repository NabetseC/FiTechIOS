import SwiftUI
import AVFoundation
import Vision

// 1.
struct ContentView: View {
    @State private var cameraViewModel = CameraViewModel()
    @State private var poseViewModel = PoseEstimationViewModel()
    
    var body: some View {
        // 2.
        ZStack {
            // 2a.
            CameraPreviewView(session: cameraViewModel.session)
                .edgesIgnoringSafeArea(.all)
            // 2b.
            PoseOverlayView(
                bodyParts: poseViewModel.detectedBodyParts,
                connections: poseViewModel.bodyConnections
            )
            if !poseViewModel.predictedLabel.isEmpty {
                    Text(poseViewModel.predictedLabel)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.black.opacity(0.6))
                        .cornerRadius(12)
                        .padding(.top, 50)
                }
        }
        .task {
            await cameraViewModel.checkPermission()
            cameraViewModel.delegate = poseViewModel
        }
    }
}
