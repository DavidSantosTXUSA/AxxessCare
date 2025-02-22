//
//  LoginView.swift
//  healthapp
//
//  Created by David Santos on 2/22/25.
//


import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Axxess Health")
                .font(.largeTitle)
                .bold()
            
            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            Button(action: {
                if email.isEmpty || password.isEmpty {
                    errorMessage = "Please enter both email and password."
                } else {
                    errorMessage = ""
                    authViewModel.login(email: email, password: password)
                }
            }) {
                Text("Login")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            
            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
            }
            
            if authViewModel.isAuthenticated {
                Text("✅ Login Successful!")
                    .foregroundColor(.green)
            }
        }
        .padding()
    }
}
