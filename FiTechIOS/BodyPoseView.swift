import SwiftUI
import Vision

struct BodyPoseView: View {
    let poseObservation: VNHumanBodyPoseObservation?
    let bodyObservation: VNHumanRectangleObservation?
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Draw body rectangle
                if let bodyObservation = bodyObservation {
                    let rect = bodyObservation.boundingBox
                    Rectangle()
                        .stroke(Color.green, lineWidth: 2)
                        .frame(
                            width: rect.width * geometry.size.width,
                            height: rect.height * geometry.size.height
                        )
                        .position(
                            x: rect.midX * geometry.size.width,
                            y: (1 - rect.midY) * geometry.size.height
                        )
                }
                
                // Draw keypoints
                if let poseObservation = poseObservation {
                    ForEach(0..<poseObservation.availableJointNames.count, id: \.self) { index in
                        let jointName = poseObservation.availableJointNames[index]
                        if let point = try? poseObservation.recognizedPoint(forJointName: jointName) {
                            Circle()
                                .fill(Color.red)
                                .frame(width: 8, height: 8)
                                .position(
                                    x: point.location.x * geometry.size.width,
                                    y: (1 - point.location.y) * geometry.size.height
                                )
                        }
                    }
                }
            }
        }
    }
} 