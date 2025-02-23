//
//  CreateAccountView.swift
//  healthapp
//
//  Created by Lukas Lindestaf on 2/22/25.
//
import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct CreateAccountView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage = ""
    @State private var role = "Patient"  // Default role is "Patient"
    @State private var roles = ["Doctor", "Patient"]  // Options for user role
    
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
            
            Picker("Select Role", selection: $role) {
                ForEach(roles, id: \.self) { role in
                    Text(role)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
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
                            // Successfully created user
                            let db = Firestore.firestore()
                            let userRef = db.collection("users").document(authResult!.user.uid)
                            userRef.setData([
                                "email": email,
                                "role": role // Store the selected role in Firestore
                            ]) { err in
                                if let err = err {
                                    errorMessage = "Error setting user role: \(err.localizedDescription)"
                                } else {
                                    authViewModel.isAuthenticated = true
                                }
                            }
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

