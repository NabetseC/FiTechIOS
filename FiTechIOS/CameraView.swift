import SwiftUI
import Vision

struct CameraView: View {
    
    @Binding var image: CGImage?
    @State private var poseObservation: VNHumanBodyPoseObservation?
    @State private var bodyObservation: VNHumanRectangleObservation?
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if let image = image {
                    Image(decorative: image, scale: 1)
                        .resizable()
                        .scaledToFill()
                        .frame(width: geometry.size.width,
                               height: geometry.size.height)
                        .clipped()
                } else {
                    ContentUnavailableView("No camera feed", systemImage: "xmark.circle.fill")
                        .frame(width: geometry.size.width,
                               height: geometry.size.height)
                }
                
                // Overlay body pose detection
                BodyPoseView(poseObservation: poseObservation, bodyObservation: bodyObservation)
            }
        }
    }
    
}
