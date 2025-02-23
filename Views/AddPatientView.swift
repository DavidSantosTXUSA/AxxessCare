//
//  AddPatientView.swift
//  healthapp
//
//  Created by David Santos on 2/23/25.
//


// AddPatientView.swift (in Views folder)
import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct AddPatientView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var patientEmail: String = ""
    @State private var errorMessage: String = ""
    
    // Closure to pass back the new patient
    var onAddPatient: (DoctorPatient) -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Patient Email")) {
                    TextField("Enter patient's email", text: $patientEmail)
                        .keyboardType(.emailAddress)
                }
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                }
            }
            .navigationTitle("Add Patient")
            .navigationBarItems(trailing: Button("Add") {
                addPatientByEmail()
            })
        }
    }
    
    func addPatientByEmail() {
        let db = FirebaseManager.shared.firestore
        db.collection("users")
            .whereField("email", isEqualTo: patientEmail)
            .getDocuments { snapshot, error in
                if let error = error {
                    errorMessage = error.localizedDescription
                    return
                }
                guard let documents = snapshot?.documents, let doc = documents.first,
                      let role = doc.data()["role"] as? String, role.lowercased() == "patient" else {
                    errorMessage = "No patient found with that email."
                    return
                }
                
                // Optionally, you might want to fetch the patient's name from their document.
                let name = doc.data()["name"] as? String ?? "Unnamed Patient"
                let patient = DoctorPatient(id: doc.documentID, name: name, email: patientEmail)
                onAddPatient(patient)
                presentationMode.wrappedValue.dismiss()
            }
    }
}
