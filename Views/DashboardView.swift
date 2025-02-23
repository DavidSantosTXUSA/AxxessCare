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
                // HEADER - LOGO & WELCOME MESSAGE
                HStack {
                    Image("axxess_2") // Ensure this is added in Assets.xcassets
                        .resizable()
                        .scaledToFit()
                        .frame(height: 50) // Adjust size accordingly
                        .padding(.leading, 10)
                    
                    Spacer()

                    // PROGRESS BAR (NOW IN TOP RIGHT)
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

                // WELCOME MESSAGE
                VStack(alignment: .leading) {
                    Text("Welcome")
                        .font(.title3)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .leading) // Left-aligned
                        .padding(.horizontal, 10)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)

                // DASHBOARD TITLE
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

                    if todayMedications.isEmpty {
                        Text("No medications scheduled for today.")
                            .foregroundColor(.gray)
                    } else {
                        List {
                            ForEach(todayMedications.indices, id: \.self) { index in
                                MedicationCard(
                                    medication: $medications[index],
                                    darkRed: darkRed,
                                    onToggleTaken: { isTaken in
                                        updateProgress(isTaken)
                                    }
                                )
                            }
                            .onDelete(perform: deleteMedication)  // Swipe to delete
                        }
                        .listStyle(PlainListStyle())
                        .frame(height: 250)  // Fix height to avoid layout shifting
                    }
                }
                .padding(.horizontal)

                Spacer() // Pushes buttons to the bottom

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

    func updateProgress(_ isTaken: Bool) {
        if isTaken {
            takenMedications += 1
        } else if takenMedications > 0 {
            takenMedications -= 1
        }
    }

    func deleteMedication(at offsets: IndexSet) {
        medications.remove(atOffsets: offsets)
        takenMedications = 0  // Reset progress and recalculate
        for medication in medications {
            if medication.isTaken {  // If any remaining medication is taken, count it
                takenMedications += 1
            }
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
    @Binding var medication: Medication
    var darkRed: Color
    @State private var isTaken: Bool = false  // Tracks button state
    var onToggleTaken: (Bool) -> Void  // Passes the new state to update progress

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

            Button(action: {
                isTaken.toggle()  // Toggle state
                onToggleTaken(isTaken)  // Pass updated state to update progress
            }) {
                Image(systemName: isTaken ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isTaken ? .green : .gray)
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

 
