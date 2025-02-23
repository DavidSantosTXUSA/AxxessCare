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
    @StateObject var patientInfoVM = PatientInfoViewModel()
    init() {
        FirebaseApp.configure() // Initialize Firebase
        print("✅ Firebase configured successfully")
    }

    var body: some Scene {
        WindowGroup {
            if authViewModel.isAuthenticated {
                DashboardView()
                    .environmentObject(authViewModel)
                    .environmentObject(patientInfoVM)
            } else {
                LoginView()
                    .environmentObject(authViewModel)
                    .environmentObject(patientInfoVM)
            }
        }
    }
}
