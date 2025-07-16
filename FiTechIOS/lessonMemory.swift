import Observation
import Vision

@Observable
class lessonMemory {
    let templateMem = [
        "good jab": 0,
        "bad jab, lack of backfoot rotation": 0,
        "bad jab, lack of front foot rotation": 0,
        "bad jab, lack of balance": 0,
        "bad jab, slow comeback": 0,
        "bad jab, offhand guarding": 0,
        "bad rest": 0,
        "good rest": 0,
        "bad straight": 0,
        "good straight": 0,
        "good kick": 0,
        "bad kick": 0,
    ]
    var longTermMem: [String: Int]
    var shortTermMem: [String: Int]
    var poseMem: [[[HumanBodyPoseObservation.JointName: CGPoint]]] = []
    var localChatHistory: [ChatMessage] = []
    var displayedPose: [HumanBodyPoseObservation.JointName: CGPoint]?
    var moveIndex = 0
    var frameIndex = 0
    var timer: Timer?
    
    
    init(){
        longTermMem = templateMem
        shortTermMem = templateMem
    }
    
    func updateMem(label: String){
        longTermMem[label]! += 1
        shortTermMem[label]! += 1
    }
    
    func resetShortMem(){
        shortTermMem = templateMem
    }
    
    func updatePoseMem(pose: [[HumanBodyPoseObservation.JointName: CGPoint]]){
        poseMem.append(pose)
    }
    func updateChatHistory(message: ChatMessage){
        localChatHistory.append(message)
    }
    
    func getScoreShort(goal: [String], max: Int) -> Double{
        var score = 0
        for move in goal{
            score += shortTermMem[move]!
        }
        let result = Double(score)/Double(max)
        return result
        
    }
    func getPose()->[HumanBodyPoseObservation.JointName: CGPoint]{
        if let pose = displayedPose{
            return pose
        }
        return [.nose: CGPoint(x: 0.5, y: 0.1)]
    }
    func next(){
        if poseMem.isEmpty{
            return
        }
        
        if frameIndex < 39 {
            frameIndex+=1
        }
        else if ((frameIndex == 39) && (moveIndex < poseMem.count-1)){
            moveIndex+=1
            frameIndex = 0
        }
        else{
            frameIndex = 0
            moveIndex = 0
        }
        displayedPose = poseMem[moveIndex][frameIndex]
    }
    func startTimer(){
        timer = Timer.scheduledTimer(withTimeInterval: 1.0/30.0, repeats: true){
            _ in
            self.next()
        }
    }
    deinit {
        timer?.invalidate()
    }
}
