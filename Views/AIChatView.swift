//
//  AIChatView.swift
//  healthapp
//
//  Created by David Santos on 2/22/25.
//


import SwiftUI

struct AIChatView: View {
    @State private var userMessage = ""
    @State private var chatLog: [String] = ["AI: Hi! I'm your health assistant. How can I help?"]
    
    let darkRed = Color(red: 139/255, green: 0, blue: 0) // Dashboard Matching Color
    
    var body: some View {
        VStack {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(chatLog.indices, id: \ .self) { index in
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
        chatLog.append("You: \(userMessage)")
        
        // Placeholder AI response
        let aiResponse = "AI: I’m here to assist you with your health-related questions!"
        chatLog.append(aiResponse)
        
        userMessage = ""
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
