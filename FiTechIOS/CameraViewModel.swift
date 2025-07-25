import SwiftUI
import AVFoundation
import Vision

@Observable
class CameraViewModel {

    // 1.
    let session = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "sessionQueue")
    private let videoDataOutputQueue = DispatchQueue(label: "videoDataOutputQueue")
    private let videoDataOutput = AVCaptureVideoDataOutput()
    weak var delegate: AVCaptureVideoDataOutputSampleBufferDelegate?
    var audioPlayer: AVAudioPlayer?
    var tickTimer: Timer?
    
    // 2.
    func checkPermission() async {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            await setupCamera()
        case .notDetermined:
            let granted = await AVCaptureDevice.requestAccess(for: .video)
            if granted {
                await setupCamera()
            }
        default:
            print("Camera permission denied")
        }
    }
    
    private func configureFrameRate(for device: AVCaptureDevice, to fps: Int32) {
        do {
            try device.lockForConfiguration()

            for format in device.formats {
                for range in format.videoSupportedFrameRateRanges {
                    if range.minFrameRate <= Double(fps), Double(fps) <= range.maxFrameRate {
                        device.activeFormat = format
                        device.activeVideoMinFrameDuration = CMTimeMake(value: 1, timescale: fps)
                        device.activeVideoMaxFrameDuration = CMTimeMake(value: 1, timescale: fps)
                        print("Frame rate set to \(fps) FPS")
                        break
                    }
                }
            }

            device.unlockForConfiguration()
        } catch {
            print("Failed to lock device for configuration: \(error)")
        }
    }

    // 3.
    private func setupCamera() async {
        sessionQueue.async {
                self.session.beginConfiguration()
                
                guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
                    print("Failed to get camera")
                    self.session.commitConfiguration()
                    return
                }

                // ✅ Set target frame rate
                self.configureFrameRate(for: videoDevice, to: 30)

                guard let videoInput = try? AVCaptureDeviceInput(device: videoDevice) else {
                    print("Failed to create video input")
                    self.session.commitConfiguration()
                    return
                }

                if self.session.canAddInput(videoInput) {
                    self.session.addInput(videoInput)
                }

                self.videoDataOutput.videoSettings = [
                    kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)
                ]

                self.videoDataOutput.setSampleBufferDelegate(self.delegate, queue: self.videoDataOutputQueue)
                self.videoDataOutput.alwaysDiscardsLateVideoFrames = true

                if self.session.canAddOutput(self.videoDataOutput) {
                    self.session.addOutput(self.videoDataOutput)
                }

                if let connection = self.videoDataOutput.connection(with: .video) {
                    connection.videoRotationAngle = 90
                    connection.isVideoMirrored = true
                }

                self.session.commitConfiguration()
                self.session.startRunning()
            }
    }
}
