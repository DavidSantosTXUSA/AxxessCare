import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage = ""
    @State private var isCreatingAccount = false

    let darkRed = Color(red: 139/255, green: 0, blue: 0) // Dark Red Color

    var body: some View {
        VStack(spacing: 20) {
            // Axxess Logo
            Image("Axxess_Logo") // Make sure this matches your asset file name
                .resizable()
                .scaledToFit()
                .frame(height: 60) // Adjust size if needed
                .padding(.top, 40)

            // Email & Password Fields
            VStack(spacing: 15) {
                TextField("Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                    .padding(.top, 10)

                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
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
            .padding(.horizontal)

            // Create Account Button
            Button(action: {
                isCreatingAccount = true
            }) {
                Text("Create Account")
                    .foregroundColor(darkRed)
                    .bold()
                    .padding()
            }
            .sheet(isPresented: $isCreatingAccount) {
                CreateAccountView()
            }

            // Error Message Display
            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
            }

            // Success Message Display
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

    let darkRed = Color(red: 139/255, green: 0, blue: 0) // Dark Red Color

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

