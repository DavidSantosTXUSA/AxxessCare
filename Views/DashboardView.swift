import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var medications: [Medication] = []
    @State private var showMedicationForm = false
    
    let darkRed = Color(red: 139/255, green: 0, blue: 0) // Dark Red Color
    let lightBackground = Color.white

    var body: some View {
        NavigationView {
            ZStack {
                lightBackground.edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 20) {
                    
                    // HEADER
                    VStack {
                        Text("Axxess Health")
                            .font(.largeTitle)
                            .bold()
                            .foregroundColor(darkRed)
                        
                        Text("Welcome, \(authViewModel.userRole == "admin" ? "Doctor" : "Patient")")
                            .font(.title2)
                            .foregroundColor(.gray)
                    }
                    
                    // MEDICATION LIST
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Today's Medications")
                            .font(.title2)
                            .bold()
                            .foregroundColor(darkRed)
                        
                        if todayMedications.isEmpty {
                            Text("No medications scheduled for today.")
                                .foregroundColor(.gray)
                        } else {
                            ScrollView {
                                ForEach(todayMedications) { medication in
                                    MedicationCard(medication: medication, darkRed: darkRed)
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 3)
                    .padding(.horizontal)
                    
                    // BUTTONS
                    VStack(spacing: 10) {
                        NavigationLink(destination: AIChatView()) {
                            Text("Chat with AI Assistant")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(darkRed)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        
                        Button(action: {
                            showMedicationForm = true
                        }) {
                            Text("Add Medication")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .sheet(isPresented: $showMedicationForm) {
                            MedicationFormView { newMedication in
                                medications.append(newMedication)
                            }
                        }
                        
                        Button(action: {
                            authViewModel.logout()
                        }) {
                            Text("Logout")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.top)
            }
            .navigationTitle("Dashboard")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    patientOrAdminProfile
                }
            }
        }
    }
    
    var todayMedications: [Medication] {
        let today = Date()
        return medications.filter { med in
            med.startDate <= today && med.endDate >= today
        }
    }
    
    // MARK: - Profile Button
    var patientOrAdminProfile: some View {
        Button(action: {
            // Navigate to profile
        }) {
            Image(systemName: "person.crop.circle")
                .imageScale(.large)
                .foregroundColor(darkRed)
        }
    }
}

// MARK: - Medication Card View
struct MedicationCard: View {
    var medication: Medication
    var darkRed: Color

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(medication.name)
                    .font(.headline)
                    .foregroundColor(darkRed)
                
                Text("Dosage: \(medication.dosage)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Text("Time: \(medication.timeOfDay)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            Spacer()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(8)
        .shadow(radius: 2)
        .padding(.horizontal, 5)
    }
}

#Preview {
    DashboardView()
}

