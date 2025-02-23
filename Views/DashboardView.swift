// DashboardView.swift
import SwiftUI
import FirebaseAuth

struct DashboardView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        NavigationView {
            Group {
                if authViewModel.userRole.lowercased() == "doctor" {
                    DoctorDashboardContent()
                } else {
                    PatientDashboardContent()
                }
            }
            .navigationBarHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    ProfileButtonView()
                }
            }
        }
    }
}

// MARK: - Patient Dashboard Content
struct PatientDashboardContent: View {
    // MedicationViewModel fetches medications from "users/{uid}/medications"
    @StateObject private var medicationVM = MedicationViewModel(userID: FirebaseManager.shared.auth.currentUser?.uid ?? "")
    @EnvironmentObject var authViewModel: AuthViewModel
    // Calculate progress based on medications marked as taken.
    var takenMedications: Int {
        medicationVM.medications.filter { $0.isTaken }.count
    }
    var totalMedications: Int {
        medicationVM.medications.count
    }
    var progress: Double {
        totalMedications > 0 ? Double(takenMedications) / Double(totalMedications) : 0
    }
    
    let darkRed = Color(red: 139/255, green: 0, blue: 0)
    
    var body: some View {
        VStack {
            // HEADER: Logo & Progress Bar
            HStack {
                Image("axxess_2")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 50)
                    .padding(.leading, 10)
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 5) {
                    Text("Medication Progress")
                        .font(.caption)
                        .foregroundColor(darkRed)
                    
                    ProgressView(value: progress, total: 1)
                        .progressViewStyle(LinearProgressViewStyle(tint: darkRed))
                        .frame(width: 120)
                    
                    Text("\(takenMedications)/\(totalMedications) taken")
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal)
            .padding(.top, 10)
            
            // WELCOME & TITLE
            VStack(alignment: .leading) {
                Text("Welcome")
                    .font(.title3)
                    .foregroundColor(.gray)
                    .padding(.horizontal, 10)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Text("Dashboard")
                .font(.largeTitle)
                .bold()
                .foregroundColor(darkRed)
                .padding(.top, 5)
            
            // MEDICATION LIST
            VStack(alignment: .leading, spacing: 10) {
                Text("Today's Medications")
                    .font(.title2)
                    .bold()
                    .foregroundColor(darkRed)
                
                if medicationVM.medications.isEmpty {
                    Text("No medications scheduled for today.")
                        .foregroundColor(.gray)
                } else {
                    List {
                        ForEach(medicationVM.medications) { medication in
                            MedicationCard(medication: medication, darkRed: darkRed, onToggleTaken: { newState in
                                var updatedMedication = medication
                                updatedMedication.isTaken = newState
                                medicationVM.updateMedication(updatedMedication)
                            })
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .padding(.horizontal)
            
            Spacer()
            
            // BOTTOM BUTTONS: Chat and Logout (Patients cannot add medications)
            VStack(spacing: 15) {
                NavigationLink(destination: AIChatView()) {
                    Text("Chat with AI Assistant")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(darkRed)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .shadow(radius: 3)
                }
                
                // "Add Medication" is disabled for patients.
                Button(action: {}) {
                    Text("Add Medication (Unavailable)")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .shadow(radius: 3)
                }
                .disabled(true)
                
                Button(action: {
                    authViewModel.logout()
                }) {
                    Text("Logout")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .shadow(radius: 3)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
    }
}

// MARK: - Doctor Dashboard Content
struct DoctorDashboardContent: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var doctorNetworkVM = DoctorNetworkViewModel(doctorUid: FirebaseManager.shared.auth.currentUser?.uid ?? "")
    @State private var showAddPatient = false
    
    let darkRed = Color(red: 139/255, green: 0, blue: 0)

    var body: some View {
        VStack(alignment: .leading) {
            // HEADER with title and "Add Patient" button.
            HStack {
                Text("Doctor Dashboard")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(darkRed)
                Spacer()
                Button(action: {
                    showAddPatient = true
                }) {
                    Text("Add Patient")
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
            }
            .padding()
            
            if doctorNetworkVM.patients.isEmpty {
                Text("No patients in your network.")
                    .foregroundColor(.gray)
                    .padding()
            } else {
                List {
                    ForEach(doctorNetworkVM.patients) { patient in
                        NavigationLink(destination: DoctorPatientMedicationsView(patient: patient)) {
                            VStack(alignment: .leading) {
                                Text(patient.name)
                                    .font(.headline)
                                Text(patient.email)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .onDelete(perform: deletePatient)  // Enables swipe-to-delete
                }
                .listStyle(PlainListStyle())
            }
            
            Spacer()
            
            Button(action: {
                authViewModel.logout()
            }) {
                Text("Logout")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding([.horizontal, .bottom])
        }
        .sheet(isPresented: $showAddPatient) {
            AddPatientView { newPatient in
                doctorNetworkVM.addPatient(newPatient)
            }
        }
    }

    // MARK: - Delete Patient Function
    private func deletePatient(at offsets: IndexSet) {
        for index in offsets {
            let patient = doctorNetworkVM.patients[index]
            //doctorNetworkVM.removePatient(patient)
        }
    }
}


// MARK: - Profile Button
struct ProfileButtonView: View {
    let darkRed = Color(red: 139/255, green: 0, blue: 0)
    var body: some View {
        Button(action: {
            // Implement profile navigation if needed.
        }) {
            Image(systemName: "person.crop.circle.fill")
                .resizable()
                .frame(width: 28, height: 28)
                .foregroundColor(darkRed)
                .shadow(radius: 3)
        }
    }
}

// MARK: - Preview
struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView().environmentObject(AuthViewModel())
    }
}
