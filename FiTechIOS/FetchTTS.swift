import Foundation
func fetchTTS(text: String, completion: @escaping (URL?) -> Void) {
    guard let url = URL(string: "https://api.openai.com/v1/audio/speech") else {
        completion(nil)
        return
    }

    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.addValue("Bearer api-key", forHTTPHeaderField: "Authorization")
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")

    let payload: [String: Any] = [
        "model": "tts-1",
        "input": text,
        "voice": "nova",
        "response_format": "mp3"
    ]

    request.httpBody = try? JSONSerialization.data(withJSONObject: payload)

    URLSession.shared.dataTask(with: request) { data, response, error in
        guard let data = data, error == nil else {
            print("TTS Request failed:", error?.localizedDescription ?? "Unknown error")
            completion(nil)
            return
        }

        // Save MP3 to temp file
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("tts.mp3")
        do {
            try data.write(to: tempURL)
            completion(tempURL)
            //playAudio(from: tempURL)
        } catch {
            print("Failed to save MP3:", error)
            completion(nil)
        }
    }.resume()
}

