// AuthViewModel.swift
import Foundation
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore
//import FirebaseFirestoreSwift

class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var userRole: String = "" // "Patient" or "Doctor"
    
    init() {
        // If already logged in, set up listener:
        if let user = FirebaseManager.shared.auth.currentUser {
            self.isAuthenticated = true
            self.setupRoleListener(for: user.uid)
        }
    }
    
    func login(email: String, password: String) {
        print("Attempting login with email: \(email)")
        
        FirebaseManager.shared.auth.signIn(withEmail: email, password: password) { [weak self] (result, error) in
            if let error = error {
                print("Login error: \(error.localizedDescription)")
                return
            }
            
            guard let self = self, let user = result?.user else { return }
            print("✅ Login successful!")
            self.setupRoleListener(for: user.uid)
            print("Attempting role lisnter")
            self.isAuthenticated = true
            
            // Set up a snapshot listener to continuously fetch the user role
            
        }
    }
    
    private func setupRoleListener(for uid: String) {
        print("Setting up role listener for uid: \(uid)")
        FirebaseManager.shared.firestore.collection("users").document(uid)
            .addSnapshotListener { [weak self] snapshot, error in
                if let error = error {
                    print("Firestore role listener error: \(error.localizedDescription)")
                    return
                }
                
                if let snapshot = snapshot {
                    print("Snapshot received, exists? \(snapshot.exists)")
                } else {
                    print("No snapshot received for uid: \(uid)")
                }
                
                if let data = snapshot?.data(), let role = data["role"] as? String {
                    DispatchQueue.main.async {
                        print("✅ User role updated: \(role)")
                        self?.userRole = role
                    }
                } else {
                    print("❌ No user role found in Firestore for uid: \(uid)")
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
