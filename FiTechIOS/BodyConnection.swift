
import SwiftUI
import Vision
import AVFoundation
import Observation

struct AngleFrame{
    let angles: [Double]
}

// 1.
struct BodyConnection: Identifiable {
    let id = UUID()
    let from: HumanBodyPoseObservation.JointName
    let to: HumanBodyPoseObservation.JointName
}

//this is more like a buffer for poses than a long term saver
struct PoseSaver{
    var poseFrames: [[HumanBodyPoseObservation.JointName: CGPoint]] = []
    
    mutating func addFrame(_ joints: [HumanBodyPoseObservation.JointName: CGPoint]){
        poseFrames.append(joints)
    }
    mutating func clear(){
        poseFrames.removeAll()
    }
}

@Observable
class PoseEstimationViewModel: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    var triggerCoach: (()->Void)?
    // 2.
    var detectedBodyParts: [HumanBodyPoseObservation.JointName: CGPoint] = [:]
    var bodyConnections: [BodyConnection] = []
    
    var angleBuffer: [AngleFrame] = []
    let predictionModel = try? GRUsmd(configuration: .init())
    var predictedLabel: String = ""
    
    var soundPlayer: AVAudioPlayer!
    
    var span = 6
    var currentTime = 0
    var mem: lessonMemory = lessonMemory()
    var minimumScore = 0.5
    var poseSaver = PoseSaver()
    

    
    
    func playSound(soundToPlay: String) {
        if let url = Bundle.main.url(forResource: soundToPlay, withExtension: "mp3"){
            do {
                soundPlayer = try! AVAudioPlayer(contentsOf: url)
                
                soundPlayer.play()
            }
        }else{
            print("Error, can't find the sound boss!")
        }
    }
    
    init(triggerCoach: (()->Void)? = nil) {
        self.triggerCoach =  triggerCoach
        super.init()
        setupBodyConnections()
    }
    
    // 3.
    private func setupBodyConnections() {
        bodyConnections = [
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
    }

    // 4.
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        Task {
            if let detectedPoints = await processFrame(sampleBuffer) {
                DispatchQueue.main.async {
                    self.detectedBodyParts = detectedPoints
                    
                    let angles = self.computeAngles(from: detectedPoints)
                    guard angles.count == 8 else {
                        self.angleBuffer.removeAll()
                        self.poseSaver.clear()
                        return
                    }

                    self.angleBuffer.append(AngleFrame(angles: angles))
                    self.poseSaver.addFrame(detectedPoints)

                    if self.angleBuffer.count == 40 {
                        self.makePrediction()
                        //self.poseSaver.addPose(self.angleBuffer)
                        
                        self.angleBuffer.removeAll() // ✅ reset buffer
                        self.poseSaver.clear()
                        self.playSound(soundToPlay: "tick")
                    }
                }
            }
        }
    }

    // 5.
    func processFrame(_ sampleBuffer: CMSampleBuffer) async -> [HumanBodyPoseObservation.JointName: CGPoint]? {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return nil }
        
        let request = DetectHumanBodyPoseRequest()
        
        do {
            let results = try await request.perform(on: imageBuffer, orientation: .none)
            if let observation = results.first {
                return extractPoints(from: observation)
            }
        } catch {
            print("Error processing frame: \(error.localizedDescription)")
        }

        return nil
    }

    // 6.
    private func extractPoints(from observation: HumanBodyPoseObservation) -> [HumanBodyPoseObservation.JointName: CGPoint] {
        var detectedPoints: [HumanBodyPoseObservation.JointName: CGPoint] = [:]
        let humanJoints: [HumanBodyPoseObservation.PoseJointsGroupName] = [.face, .torso, .leftArm, .rightArm, .leftLeg, .rightLeg]
        
        for groupName in humanJoints {
            let jointsInGroup = observation.allJoints(in: groupName)
            for (jointName, joint) in jointsInGroup {
                if joint.confidence > 0.5 { // Ensuring only high-confidence joints are added
                    let point = joint.location.verticallyFlipped().cgPoint
                    detectedPoints[jointName] = point
                }
            }
        }
        return detectedPoints
    }
    private func computeAngles(from joints: [HumanBodyPoseObservation.JointName: CGPoint]) -> [Double] {
            func angleBetween(_ a: CGPoint, _ b: CGPoint, _ c: CGPoint) -> Double {
                let ab = CGVector(dx: b.x - a.x, dy: b.y - a.y)
                let cb = CGVector(dx: b.x - c.x, dy: b.y - c.y)
                let dotProduct = ab.dx * cb.dx + ab.dy * cb.dy
                let abMag = sqrt(ab.dx * ab.dx + ab.dy * ab.dy)
                let cbMag = sqrt(cb.dx * cb.dx + cb.dy * cb.dy)
                let angle = acos(dotProduct / max(abMag * cbMag, 1e-5)) / .pi
                return angle
            }

        guard
            // Right-side joints
            let rshoulder = joints[.rightShoulder],
            let relbow = joints[.rightElbow],
            let rwrist = joints[.rightWrist],
            let rhip = joints[.rightHip],
            let rknee = joints[.rightKnee],
            let rankle = joints[.rightAnkle],

            // Left-side joints
            let lshoulder = joints[.leftShoulder],
            let lelbow = joints[.leftElbow],
            let lwrist = joints[.leftWrist],
            let lhip = joints[.leftHip],
            let lknee = joints[.leftKnee],
            let lankle = joints[.leftAnkle]

        else {
            return []
        }

        return [
            // Right side angles
            angleBetween(rshoulder, relbow, rwrist),
            angleBetween(relbow, rshoulder, rhip),
            angleBetween(rshoulder, rhip, rknee),
            angleBetween(rhip, rknee, rankle),

            // Left side angles
            angleBetween(lshoulder, lelbow, lwrist),
            angleBetween(lelbow, lshoulder, lhip),
            angleBetween(lshoulder, lhip, lknee),
            angleBetween(lhip, lknee, lankle)
        ]
        }
    func makePrediction() {
        guard let model = predictionModel else { return }

        let inputArray = angleBuffer.flatMap { $0.angles }
        let mlArray = try? MLMultiArray(shape: [1, 40, 8], dataType: .double)

        for (index, value) in inputArray.enumerated() {
            mlArray?[index] = NSNumber(value: value)
        }

        guard let input = try? GRUsmdInput(input_3: mlArray!) else { return }
        guard let result = try? model.prediction(input: input) else { return }

        // Replace "output" with your model’s actual output name
        let outputArray = result.Identity
        let floatValues = (0..<outputArray.count).map { outputArray[$0].floatValue }

        if let predictedIndex = floatValues.enumerated().max(by: { $0.element < $1.element })?.offset {
            let val_pred = [
                "good jab", "bad jab, lack of backfoot rotation",
                "good straight", "bad straight",
                "good rest", "bad rest",
                "good kick", "bad kick"
            ]
            // ATTENTION futre me, I am hardcoding good jab in to this lecture, fix that when you finish the thing you are doing
            
            let predictedLabel = val_pred[predictedIndex]
            if predictedLabel != "good jab"{
                mem.updatePoseMem(pose: poseSaver.poseFrames)
            }
                    
            print("Prediction: \(predictedLabel)")
            currentTime += 1
            mem.updateMem(label: predictedLabel)
            if currentTime == span {
                var command = ""
                let result = mem.getScoreShort(goal: ["good jab"], max: span)
                if result <= minimumScore{
                    print("bad job")
                    triggerCoach?()
                    mem.startTimer()
                }
                else {
                    if result < 1 {
                        command = "fix"
                    }
                    else{
                        command = "compliment"
                        
                    }
                    fetchChatResponse(userInput: "\(mem.shortTermMem) \(command)", asRole: "user") {response in
                        
                        DispatchQueue.main.async{
                            fetchTTS(text: response ?? "No response") { url in
                                if let url = url{
                                    audioManager.playAudio(from: url){
                                        //start listening to voice
                                    }
                                }
                                
                            }
                            self.mem.updateChatHistory(message: ChatMessage(role:"assistant", content: response ?? "No response"))
                        }
                    }
                }
                mem.resetShortMem()
                currentTime = 0
                poseSaver.clear()
                
            }
            
            DispatchQueue.main.async {
                        self.predictedLabel = predictedLabel
            }
        }
    }
}
