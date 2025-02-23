// AIChatView.swift
import SwiftUI

struct AIChatView: View {
    @State private var userMessage: String = ""
    @State private var chatLog: [String] = ["AI: Hi! I'm your health assistant. How can I help?"]
    
    // Fetch patient profile info
    @EnvironmentObject var patientInfoVM: PatientInfoViewModel
    // Fetch patient medications from Firebase using the current user's UID
    @StateObject private var medicationVM = MedicationViewModel(userID: FirebaseManager.shared.auth.currentUser?.uid ?? "")
    
    let darkRed = Color(red: 139/255, green: 0, blue: 0)
    
    var body: some View {
        VStack {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(chatLog.indices, id: \.self) { index in
                            ChatBubble(message: chatLog[index])
                                .id(index)
                        }
                    }
                    .padding()
                }
                .onChange(of: chatLog.count) { _ in
                    withAnimation {
                        proxy.scrollTo(chatLog.count - 1, anchor: .bottom)
                    }
                }
            }
            
            HStack {
                TextField("Type your message...", text: $userMessage)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(20)
                
                Button(action: sendMessage) {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.white)
                        .padding()
                        .background(darkRed)
                        .clipShape(Circle())
                }
            }
            .padding()
        }
        .navigationTitle("AI Assistant")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    func sendMessage() {
        guard !userMessage.isEmpty else { return }
        
        // Append the user's message to the chat log
        chatLog.append("You: \(userMessage)")
        
        // Build the context string from patient info and medications
        var context = ""
        if let info = patientInfoVM.patientInfo {
            context += "Patient Info: Name: \(info.name), Age: \(info.age), Gender: \(info.gender), Contact: \(info.contactNumber).\n"
        }
        if !medicationVM.medications.isEmpty {
            context += "Current Medications:\n"
            for med in medicationVM.medications {
                context += "- \(med.name) (Dosage: \(med.dosage), Frequency: \(med.frequency), Time: \(med.timeOfDay)).\n"
            }
        }
        
        // Combine context with the user's question
        let prompt = "\(context)\nUser question: \(userMessage)"
        print("Sending prompt to ChatGPT: \(prompt)")
        
        // Send the prompt to ChatGPT using the API call
        sendPromptToChatGPT(prompt: prompt) { response in
            DispatchQueue.main.async {
                self.chatLog.append("AI: \(response)")
            }
        }
        
        userMessage = ""
    }
    
    func sendPromptToChatGPT(prompt: String, completion: @escaping (String) -> Void) {
        // Retrieve the API key from Info.plist.
        // (Your Info.plist file is automatically created by Xcode in your project.
        // Open it in the Project Navigator, and add a key named "OpenAIAPIKey" with your key as its value.)
        guard let apiKey = Bundle.main.object(forInfoDictionaryKey: "OpenAI_API_KEY") as? String, !apiKey.isEmpty else {
            print("OpenAI API key not found in Info.plist")
            completion("Error: API key missing")
            return
        }
        
        // Set up the OpenAI Chat Completions endpoint
        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else {
            completion("Error: Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        // Build the JSON payload with your chosen model and parameters
        let parameters: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": [
                ["role": "system", "content": "You are a helpful assistant that incorporates patient context."],
                ["role": "user", "content": prompt]
            ],
            "max_tokens": 150,
            "temperature": 0.7
        ]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: parameters)
            request.httpBody = jsonData
        } catch {
            print("Error serializing JSON: \(error)")
            completion("Error serializing JSON")
            return
        }
        
        // Perform the API request
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error in API call: \(error)")
                completion("Error: \(error.localizedDescription)")
                return
            }
            guard let data = data else {
                completion("Error: No data returned")
                return
            }
            do {
                // Parse the response JSON to extract the generated message
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let choices = json["choices"] as? [[String: Any]],
                   let message = choices.first?["message"] as? [String: Any],
                   let content = message["content"] as? String {
                    completion(content)
                } else {
                    completion("Error parsing response")
                }
            } catch {
                completion("Error parsing JSON: \(error.localizedDescription)")
            }
        }.resume()
    }
}

struct ChatBubble: View {
    let message: String
    
    var body: some View {
        HStack {
            if message.hasPrefix("AI:") {
                Text(message)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(15)
                    .frame(maxWidth: 250, alignment: .leading)
                Spacer()
            } else {
                Spacer()
                Text(message)
                    .padding()
                    .background(Color.blue.opacity(0.8))
                    .foregroundColor(.white)
                    .cornerRadius(15)
                    .frame(maxWidth: 250, alignment: .trailing)
            }
        }
    }
}
