import AVFoundation
import SwiftUI
import Observation
import Vision

struct FeedbackScreen: View {
    var bodyConnections = [
        BodyConnection(from: .nose, to: .neck),
        BodyConnection(from: .neck, to: .rightShoulder),
        BodyConnection(from: .neck, to: .leftShoulder),
        BodyConnection(from: .rightShoulder, to: .rightHip),
        BodyConnection(from: .leftShoulder, to: .leftHip),
        BodyConnection(from: .rightHip, to: .leftHip),
        BodyConnection(from: .rightShoulder, to: .rightElbow),
        BodyConnection(from: .rightElbow, to: .rightWrist),
        BodyConnection(from: .leftShoulder, to: .leftElbow),
        BodyConnection(from: .leftElbow, to: .leftWrist),
        BodyConnection(from: .rightHip, to: .rightKnee),
        BodyConnection(from: .rightKnee, to: .rightAnkle),
        BodyConnection(from: .leftHip, to: .leftKnee),
        BodyConnection(from: .leftKnee, to: .leftAnkle)
    ]
    var memory: lessonMemory
    init(mem: lessonMemory){
        self.memory = mem
    }
    
    var body: some View {
        ZStack{
            PoseOverlayView(bodyParts: memory.getPose(), connections: bodyConnections)
            Text("FeedbackScreen")
        }
        
        
    }
    
}
