//  LoginView.swift
//  healthapp
//
//  Created by David Santos on 2/22/25.
//

import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage = ""
    @State private var isCreatingAccount = false
    
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
                    Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                        if let error = error {
                            errorMessage = error.localizedDescription
                        } else {
                            authViewModel.isAuthenticated = true
                        }
                    }
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
            
            Button(action: {
                isCreatingAccount = true
            }) {
                Text("Create Account")
                    .foregroundColor(.blue)
                    .padding()
            }
            .sheet(isPresented: $isCreatingAccount) {
                CreateAccountView()
            }
            
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

struct CreateAccountView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Create Account")
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
                    errorMessage = "Please fill out all fields."
                } else {
                    errorMessage = ""
                    Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                        if let error = error {
                            errorMessage = error.localizedDescription
                        } else {
                            authViewModel.isAuthenticated = true
                        }
                    }
                }
            }) {
                Text("Sign Up")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            
            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
            }
        }
        .padding()
    }
}
