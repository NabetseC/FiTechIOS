import Foundation

struct ChatMessage: Codable, Hashable {
    let role: String  // "user" or "assistant"
    let content: String
}

struct ChatRequest: Codable {
    let model: String
    let messages: [ChatMessage]
}

struct ChatResponse: Codable {
    struct Choice: Codable {
        struct Message: Codable {
            let content: String
        }
        let message: Message
    }
    let choices: [Choice]
}

func fetchChatResponse(userInput: String, asRole: String, completion: @escaping (String?) -> Void) {
    chatHistory.append(ChatMessage(role: asRole, content: userInput))

    let url = URL(string: "https://api.openai.com/v1/chat/completions")!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    
    // ❗ Replace with your actual API key
    request.addValue("Bearer api-key", forHTTPHeaderField: "Authorization")
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")

    let requestBody = ChatRequest(model: "gpt-4o-mini", messages: chatHistory)
    
    do {
        let jsonData = try JSONEncoder().encode(requestBody)
        request.httpBody = jsonData
    } catch {
        print("Failed to encode request: \(error)")
        return
    }
    
    URLSession.shared.dataTask(with: request) { data, _, error in
        guard let data = data, error == nil else {
            print("Request failed: \(error?.localizedDescription ?? "Unknown error")")
            completion(nil)
            return
        }
        do {
            let decodedResponse = try JSONDecoder().decode(ChatResponse.self, from: data)
            let reply = decodedResponse.choices.first?.message.content
            completion(reply)
            chatHistory.append(ChatMessage(role: "assistant", content: reply ?? ""))
        } catch {
            print("Failed to decode response: \(error)")
            completion(nil)
        }
    }.resume()
}
