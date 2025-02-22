//
//  AuthViewModel.swift
//  healthapp
//
//  Created by David Santos on 2/22/25.
//


import Foundation
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore

class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var userRole: String = "" // "patient" or "admin"

    func login(email: String, password: String) {
        print("Attempting login with email: \(email)")

        FirebaseManager.shared.auth.signIn(withEmail: email, password: password) { [weak self] (result: AuthDataResult?, error: Error?) in
            if let error = error {
                print("Login error: \(error.localizedDescription)")
                return
            }

            print("✅ Login successful!")

            self?.isAuthenticated = true

            // Fetch user role from Firestore
            guard let uid = result?.user.uid else { return }
            print("Fetching user role for UID: \(uid)")

            FirebaseManager.shared.firestore.collection("users")
                .document(uid)
                .getDocument { (snapshot, error) in
                    if let error = error {
                        print("Firestore error: \(error.localizedDescription)")
                    } else if let data = snapshot?.data(), let role = data["role"] as? String {
                        print("✅ User role fetched: \(role)")
                        self?.userRole = role
                    } else {
                        print("❌ No user role found in Firestore.")
                    }
                }
        }
    }

    func logout() {
        do {
            try FirebaseManager.shared.auth.signOut()
            isAuthenticated = false
            userRole = ""
        } catch {
            print("Logout error: \(error.localizedDescription)")
        }
    }
}
