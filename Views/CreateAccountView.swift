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
    @State private var name = ""
    @State private var age = ""
    @State private var gender = ""
    @State private var contactNumber = ""
    @State private var email = ""
    @State private var password = ""
    @State private var role = "Patient"  // Default role is "Patient"
    @State private var roles = ["Doctor", "Patient"]
    @State private var errorMessage = ""

    var body: some View {
        VStack(spacing: 15) {
            Text("Create Account")
                .font(.largeTitle)
                .bold()
            
            TextField("Full Name", text: $name)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            TextField("Age", text: $age)
                .keyboardType(.numberPad)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            TextField("Gender", text: $gender)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            TextField("Contact Number", text: $contactNumber)
                .keyboardType(.phonePad)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

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
                guard let ageInt = Int(age) else {
                    errorMessage = "Please enter a valid age."
                    return
                }
                
                registerUser(email: email, password: password, name: name, age: ageInt, gender: gender, contactNumber: contactNumber, role: role) { error in
                    if let error = error {
                        errorMessage = error.localizedDescription
                    } else {
                        authViewModel.isAuthenticated = true
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

// ✅ Firebase Registration Function to Save User Data
func registerUser(email: String, password: String, name: String, age: Int, gender: String, contactNumber: String, role: String, completion: @escaping (Error?) -> Void) {
    Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
        if let error = error {
            completion(error)
            return
        }

        guard let uid = authResult?.user.uid else { return }

        let userData: [String: Any] = [
            "email": email,
            "name": name,
            "age": age,
            "gender": gender,
            "contactNumber": contactNumber,
            "role": role
        ]

        Firestore.firestore().collection("users").document(uid).setData(userData) { error in
            completion(error)
        }
    }
}


