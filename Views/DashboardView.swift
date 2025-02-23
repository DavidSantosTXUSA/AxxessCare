import SwiftUI



struct DashboardView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var medications: [Medication] = []
    @State private var showMedicationForm = false

    var body: some View {
        NavigationView {
            VStack {
                Text("Welcome to Axxess Health!")
                    .font(.title)
                    .padding()
                
                if authViewModel.userRole == "admin" {
                    Text("You are logged in as Doctor")
                } else {
                    Text("You are logged in as Patient")
                }
                
                Text("Today's Medications").font(.title2).padding()
                List(todayMedications) { medication in
                    VStack(alignment: .leading) {
                        Text(medication.name).font(.headline)
                        Text("Dosage: \(medication.dosage)")
                        Text("Time: \(medication.timeOfDay)")
                    }
                }
                .listStyle(PlainListStyle())
                
                NavigationLink(destination: AIChatView()) {
                    Text("Chat with AI Assistant")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding()
                
                Button(action: {
                    showMedicationForm = true
                }) {
                    Text("Add Medication")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(10)
                }
                .padding()
                .sheet(isPresented: $showMedicationForm) {
                    MedicationFormView { newMedication in
                        medications.append(newMedication)
                    }
                }
                
                Button("Logout") {
                    authViewModel.logout()
                }
                .foregroundColor(.red)
                .padding()
            }
            .navigationTitle("Dashboard")
        }
    }
    
    var todayMedications: [Medication] {
        let today = Date()
        return medications.filter { med in
            med.startDate <= today && med.endDate >= today
        }
    }




    // MARK: - Custom Navigation Items for Doctor
    var doctorNavItems: some View {
        HStack {
            Button(action: {
                // Action for appointments
            }) {
                Label("Appointments", systemImage: "calendar")
            }

            Button(action: {
                // Action for managing patients
            }) {
                Label("Patients", systemImage: "person.3")
            }
        }
    }

    // MARK: - Profile Button for Both Roles
    var patientOrAdminProfile: some View {
        Button(action: {
            // Navigate to profile
        }) {
            Image(systemName: "person.crop.circle")
                .imageScale(.large)
        }
    }
}
