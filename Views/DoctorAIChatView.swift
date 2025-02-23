import SwiftUI

struct DoctorAIChatView: View {
    @State private var userMessage: String = ""
    @State private var chatLog: [String] = ["AI: Hi Doctor! I'm your health assistant. How can I help?"]

    // Fetch doctor's patient list from DoctorNetworkViewModel
    @StateObject private var doctorNetworkVM: DoctorNetworkViewModel
    
    let darkRed = Color(red: 139/255, green: 0, blue: 0)
    
    init(doctorUid: String) {
        _doctorNetworkVM = StateObject(wrappedValue: DoctorNetworkViewModel(doctorUid: doctorUid))
    }
    
    var body: some View {
        VStack {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(chatLog.indices, id: \.self) { index in
                            DoctorChatBubble(message: chatLog[index])
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
                TextField("Ask about your patients...", text: $userMessage)
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
        .navigationTitle("AI Assistant (Doctor)")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Send Message with Full Patient Context
    func sendMessage() {
        guard !userMessage.isEmpty else { return }
        
        // Append the doctor's message
        chatLog.append("You: \(userMessage)")
        
        // Fetch patients and medications for full context
        fetchPatientsWithMedications { context in
            let prompt = "\(context)\nDoctor's question: \(userMessage)"
            print("Sending prompt to ChatGPT: \(prompt)")
            
            // Send to ChatGPT
            sendPromptToChatGPT(prompt: prompt) { response in
                DispatchQueue.main.async {
                    self.chatLog.append("AI: \(response)")
                }
            }
        }
        
        userMessage = ""
    }
    
    // MARK: - Fetch Patients + Medications
    func fetchPatientsWithMedications(completion: @escaping (String) -> Void) {
        var context = "Doctor's Patient List and Medications:\n"
        let group = DispatchGroup()
        
        for patient in doctorNetworkVM.patients {
            context += "- \(patient.name) (\(patient.email))\n"
            context += "  Medications:\n"
            
            group.enter()
            FirebaseManager.shared.firestore.collection("users")
                .document(patient.id)
                .collection("medications")
                .getDocuments { snapshot, error in
                    if let error = error {
                        context += "  ⚠️ Error fetching medications: \(error.localizedDescription)\n"
                    } else if let documents = snapshot?.documents, !documents.isEmpty {
                        for doc in documents {
                            let medName = doc.data()["name"] as? String ?? "Unknown"
                            let dosage = doc.data()["dosage"] as? String ?? "Unknown dosage"
                            context += "    • \(medName) - \(dosage)\n"
                        }
                    } else {
                        context += "    No medications listed.\n"
                    }
                    group.leave()
                }
        }
        
        group.notify(queue: .main) {
            completion(context)
        }
    }
    
    // MARK: - Send Prompt to ChatGPT
    func sendPromptToChatGPT(prompt: String, completion: @escaping (String) -> Void) {
        guard let apiKey = Bundle.main.object(forInfoDictionaryKey: "OpenAI_API_KEY") as? String, !apiKey.isEmpty else {
            print("OpenAI API key not found in Info.plist")
            completion("Error: API key missing")
            return
        }
        
        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else {
            completion("Error: Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        let parameters: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": [
                ["role": "system", "content": "You are a helpful medical assistant. You can view patient names, emails, and prescribed medications to assist doctors."],
                ["role": "user", "content": prompt]
            ],
            "max_tokens": 200,
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

// MARK: - ChatBubble Component
struct DoctorChatBubble: View {
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
