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

    var body: some View {
        VStack {
            ScrollView {
                ForEach(chatLog, id: \.self) { message in
                    Text(message)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: message.hasPrefix("AI:") ? .leading : .trailing)
                        .background(message.hasPrefix("AI:") ? Color.gray.opacity(0.2) : Color.blue.opacity(0.2))
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
            }

            HStack {
                TextField("Type your message...", text: $userMessage)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                Button("Send") {
                    sendMessage()
                }
                .padding(.horizontal)
            }
            .padding()
        }
        .navigationTitle("AI Assistant")
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
