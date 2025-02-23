//
//  NavigationBarView.swift
//  healthapp
//
//  Created by Omer Erturk on 2/22/25.
//

import SwiftUI

struct ContentView: View {
    @State private var isDoctor = false // Toggle for demo purposes

    var body: some View {
        NavigationView {
            VStack {
                if isDoctor {
                    DoctorView()
                } else {
                    PatientView()
                }
                
                // Toggle between views for testing
                Button(action: {
                    isDoctor.toggle()
                }) {
                    Text("Switch to \(isDoctor ? "Patient" : "Doctor") View")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding()
            }
        }
    }
}

struct PatientView: View {
    var body: some View {
        VStack {
            Text("Welcome, Patient!")
                .font(.largeTitle)
        }
        .navigationTitle("Patient Dashboard")
        .navigationBarItems(trailing: Button("Profile") {
            // Action for patient profile
        })
    }
}

struct DoctorView: View {
    var body: some View {
        VStack {
            Text("Welcome, Doctor!")
                .font(.largeTitle)
        }
        .navigationTitle("Doctor Dashboard")
        .navigationBarItems(
            leading: Button("Appointments") {
                // Action for appointments
            },
            trailing: Button("Profile") {
                // Action for doctor profile
            }
        )
    }
}
