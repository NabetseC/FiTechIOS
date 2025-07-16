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
    @State private var inputText = ""
    @State private var chatResponse = ""
    @FocusState var isFocused: Bool
    @StateObject private var speechRecognizer = SpeechRecognizer()
    @State private var isListening = false
    @State private var leaving = false

    let audioManager = AudioManager()

    
    var body: some View {
        NavigationStack{
            ZStack{
                PoseOverlayView(bodyParts: memory.getPose(), connections: bodyConnections)
                //Text("FeedbackScreen")
                ScrollView{
                    VStack {
                        ForEach(memory.localChatHistory, id: \.self){ message in
                            if message.role != "system"{
                                ChatBubbleView(message: message)
                                .padding(.vertical, 2)
                            }
                        }
                        Spacer()
                        HStack{
                            TextEditor(text: $inputText)
                                .frame(height: 100)
                                .padding()
                                .focused($isFocused)
                            
                            Button("Send") {
                                sendTextToChat(hear: true, sentText: inputText)
                            }
                            .padding()
                            
                            Button(action: {
                                hearUserInput()
                            }) {
                                Image(systemName: isListening ? "mic.fill" : "mic")
                                    .padding()
                            }
                            
                            
                            
                            Spacer()
                        }.toolbar{
                            ToolbarItemGroup(placement: .keyboard){
                                Button("Done"){
                                    isFocused = false
                                }
                            }
                        }
                    }.background(Color.white.opacity(0.2))
                }
            }
            
            
        }
        .onAppear{
            print("I AM GODDAMN MR TERRIFIC!")
            sendTextToChat(hear: true, display:false, sentText: "\(memory.shortTermMem)")
            //hearUserInput()
        }
        .onDisappear{
            print("I AM NO LONGER GODDAMN MR TERRIFIC!")
            leaving = true
        }
            
    }
    func sendTextToChat(hear: Bool = false, display: Bool = true, sentText: String) {
        let userText = sentText
        inputText = ""
        if display{
            memory.localChatHistory.append(ChatMessage(role: "user", content: userText))
        }
        fetchChatResponse(userInput: userText, asRole: "user") { response in
            DispatchQueue.main.async {
                let reply = response ?? "No response"
                memory.localChatHistory.append(ChatMessage(role: "assistant", content: reply))
                //creates loop, hear, speak, hear, speak...
                
                fetchTTS(text: reply){ url in
                    print("TTS obrained!")
                    if let url = url, hear {
                        audioManager.playAudio(from: url) {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                
                                    hearUserInput()
                            }
                        }
                    }
                }
                
            }
        }
    }
    func hearUserInput() {
        if isListening || leaving {
            speechRecognizer.stopRecording()
            isListening = false
            return
        }

        requestPermissions { granted in
            if granted {
                do {
                    isListening = true
                    try speechRecognizer.startRecording { transcript in
                        DispatchQueue.main.async {
                            if self.isListening {
                                self.inputText = transcript
                                self.isListening = false
                                self.sendTextToChat(hear: true, sentText: self.inputText)
                            }
                        }
                    }
                } catch {
                    print("Error starting recording: \(error)")
                    isListening = false
                }
            } else {
                print("Permission denied")
            }
        }
    }}
