//
//  AxxessHealthAppApp.swift
//  healthapp
//
//  Created by David Santos on 2/22/25.
//


import SwiftUI
import Firebase

@main
struct AxxessHealthAppApp: App {
    @StateObject var authViewModel = AuthViewModel()

    init() {
        FirebaseApp.configure() // Initialize Firebase
        print("✅ Firebase configured successfully")
    }

    var body: some Scene {
        WindowGroup {
            if authViewModel.isAuthenticated {
                DashboardView()
                    .environmentObject(authViewModel)
            } else {
                LoginView()
                    .environmentObject(authViewModel)
            }
        }
    }
}
