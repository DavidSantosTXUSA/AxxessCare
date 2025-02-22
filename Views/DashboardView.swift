//
//  DashboardView.swift
//  healthapp
//
//  Created by David Santos on 2/22/25.
//


import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        NavigationView {
            VStack {
                Text("Welcome to Axxess Health!")
                    .font(.title)
                    .padding()

                if authViewModel.userRole == "admin" {
                    Text("You are logged in as Admin")
                } else {
                    Text("You are logged in as Patient")
                }

                NavigationLink(destination: AIChatView()) {
                    Text("Chat with AI Assistant")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding()

                Button("Logout") {
                    authViewModel.logout()
                }
                .foregroundColor(.red)
                .padding()
            }
        }
    }
}
