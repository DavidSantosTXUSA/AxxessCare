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
    
    let darkRed = Color(red: 139/255, green: 0, blue: 0) // Dashboard Matching Color
    
    var body: some View {
        ZStack {
            Color.white.edgesIgnoringSafeArea(.all) // Background Color
            
            VStack(spacing: 20) {
                // Axxess Logo
                Image("Axxess_Logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 80) // Adjust size as needed
                    .padding(.top, 40)
                
                // Input Fields
                VStack(spacing: 15) {
                    TextField("Email", text: $email)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .padding(.horizontal, 30)

                    SecureField("Password", text: $password)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .padding(.horizontal, 30)
                }
                
                // Error Message
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding(.top, 5)
                }
                
                // Login Button
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
                        .background(darkRed)
                        .cornerRadius(10)
                }
                .padding(.horizontal, 30)
                .shadow(radius: 3)

                // Create Account Button
                Button(action: {
                    isCreatingAccount = true
                }) {
                    Text("Create Account")
                        .foregroundColor(darkRed)
                        .font(.headline)
                }
                .padding(.top, 10)
                .sheet(isPresented: $isCreatingAccount) {
                    CreateAccountView()
                }
            }
            .padding()
        }
    }
}

struct CreateAccountView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage = ""
    
    let darkRed = Color(red: 139/255, green: 0, blue: 0) // Matching Color
    
    var body: some View {
        VStack(spacing: 20) {
            Image("Axxess_Logo")
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 80)
                .padding(.top, 40)
            
            TextField("Email", text: $email)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal, 30)
            
            SecureField("Password", text: $password)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal, 30)
            
            // Error Message
            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding(.top, 5)
            }
            
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
            .padding(.horizontal, 30)
            .shadow(radius: 3)
        }
        .padding()
    }
}

