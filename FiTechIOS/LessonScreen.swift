import SwiftUI
import AVFoundation
import Vision

// 1.
struct LessonScreen: View {
    @State private var toCoach: Bool = false
    @State private var cameraViewModel = CameraViewModel()
    @State private var poseViewModel : PoseEstimationViewModel? = nil
    
    var body: some View {
        // 2.
        NavigationStack{
            ZStack {
                // 2a.
                CameraPreviewView(session: cameraViewModel.session)
                    .edgesIgnoringSafeArea(.all)
                // 2b.
                if let viewModel = poseViewModel {
                    
                    if toCoach == false{
                            PoseOverlayView(
                                bodyParts: viewModel.detectedBodyParts,
                                connections: viewModel.bodyConnections
                            )
                        
                    }
                    Button("Ask Coach"){
                        toCoach = true
                    }
                    .navigationDestination(isPresented: $toCoach){
                        FeedbackScreen(mem: viewModel.mem)
                    }
                        if !viewModel.predictedLabel.isEmpty {
                            Text(viewModel.predictedLabel)
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.black.opacity(0.6))
                                .cornerRadius(12)
                                .padding(.top, 50)
                    }
                }
            }
            .task {
                if poseViewModel == nil {
                    poseViewModel = PoseEstimationViewModel(triggerCoach: {
                        toCoach = true
                    })
                    cameraViewModel.delegate = poseViewModel
                }
                await cameraViewModel.checkPermission()
            }
        }
    }
}
