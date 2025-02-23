import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var medications: [Medication] = []
    @State private var takenMedications: Int = 0
    @State private var showMedicationForm = false
    
    let darkRed = Color(red: 139/255, green: 0, blue: 0) // Dark Red Color
    let lightBackground = Color.white

    var body: some View {
        NavigationView {
            VStack {
                // TOP SECTION - Axxess Health & Welcome Message
                VStack(alignment: .leading) {
                    Text("Axxess Health")
                        .font(.title)
                        .bold()
                        .foregroundColor(darkRed)

                    Text("Welcome, \(authViewModel.userRole == "admin" ? "Doctor" : "Patient")")
                        .font(.title3)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                .padding(.top, 10)

                // CENTERED DASHBOARD TITLE
                Text("Dashboard")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(darkRed)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 5)

                // PROGRESS BAR SECTION
                VStack(spacing: 10) {
                    Text("Medication Progress")
                        .font(.headline)
                        .foregroundColor(darkRed)
                    
                    ProgressView(value: progress, total: 1)
                        .progressViewStyle(LinearProgressViewStyle(tint: darkRed))
                        .frame(width: 250)
                    
                    Text("\(takenMedications)/\(totalMedications) taken")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .shadow(radius: 3)
                .padding(.horizontal)

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
                                MedicationCard(medication: medication, darkRed: darkRed, onTaken: {
                                    markMedicationAsTaken()
                                })
                            }
                        }
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .shadow(radius: 3)
                .padding(.horizontal)

                Spacer() // PUSHES BUTTONS TO THE BOTTOM

                // BOTTOM BUTTONS
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

                    Button(action: {
                        showMedicationForm = true
                    }) {
                        Text("Add Medication")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .shadow(radius: 3)
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
                            .cornerRadius(12)
                            .shadow(radius: 3)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 20) // Ensure space from the bottom
            }
            .navigationBarHidden(true) // Hide default navigation title
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

    var totalMedications: Int {
        return todayMedications.count
    }
    
    var progress: Double {
        return totalMedications > 0 ? Double(takenMedications) / Double(totalMedications) : 0
    }

    func markMedicationAsTaken() {
        if takenMedications < totalMedications {
            takenMedications += 1
        }
    }
    
    // MARK: - Profile Button
    var patientOrAdminProfile: some View {
        Button(action: {
            // Navigate to profile
        }) {
            Image(systemName: "person.crop.circle.fill")
                .resizable()
                .frame(width: 28, height: 28)
                .foregroundColor(darkRed)
                .shadow(radius: 3)
        }
    }
}

// MARK: - Medication Card View
struct MedicationCard: View {
    var medication: Medication
    var darkRed: Color
    var onTaken: () -> Void

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
            
            Button(action: onTaken) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .font(.title)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 3)
        .padding(.horizontal, 5)
    }
}

#Preview {
    DashboardView()
}

