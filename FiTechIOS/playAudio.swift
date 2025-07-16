import AVFoundation
import Speech

var player: AVAudioPlayer?
var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
import AVFoundation
//AudioManager for chat speech to allow for realistic talking
class AudioManager: NSObject, AVAudioPlayerDelegate {
    var player: AVAudioPlayer?
    private var onFinish: (() -> Void)?

    func playAudio(from url: URL, onFinish: @escaping () -> Void) {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            player = try AVAudioPlayer(contentsOf: url)
            self.onFinish = onFinish
            player?.delegate = self
            player?.prepareToPlay()
            player?.play()
        } catch {
            print("Error playing audio:", error)
        }
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        do {
            try AVAudioSession.sharedInstance().setActive(false)
        } catch {
            print("Error deactivating audio session: \(error)")
        }
        onFinish?()
    }
}

// function to play any audio
func playAudio(from url: URL?) {
    guard let url = url else {
        print("No URL provided for audio.")
        return
    }
    
    do {
        player = try AVAudioPlayer(contentsOf: url)
        player?.prepareToPlay()
        player?.play()
    } catch {
        print("Error playing audio:", error)
    }
}


func requestPermissions(completion: @escaping (Bool) -> Void) {
    SFSpeechRecognizer.requestAuthorization { authStatus in
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            DispatchQueue.main.async {
                let isAllowed = authStatus == .authorized && granted
                completion(isAllowed)
            }
        }
    }
}
