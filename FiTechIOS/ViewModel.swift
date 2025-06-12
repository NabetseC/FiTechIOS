import Foundation
import CoreImage
import Observation
import Vision

@Observable
class ViewModel {
    var currentFrame: CGImage?
    var poseObservation: VNHumanBodyPoseObservation?
    var bodyObservation: VNHumanRectangleObservation?
    
    private let cameraManager = CameraManager()
    
    init() {
        Task {
            await handleCameraPreviews()
        }
        
        // Set up body detection callback
        cameraManager.onBodyDetection = { [weak self] pose, body in
            self?.poseObservation = pose
            self?.bodyObservation = body
        }
    }
    
    func handleCameraPreviews() async {
        for await image in cameraManager.previewStream {
            Task { @MainActor in
                currentFrame = image
            }
        }
    }
}
