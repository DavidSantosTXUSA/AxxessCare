//
//  AddPatientView.swift
//  healthapp
//

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
                      let role = doc.data()["role"] as? String,
                      role.lowercased() == "patient" else {
                    errorMessage = "No patient found with that email."
                    return
                }
                
                let name = doc.data()["name"] as? String ?? "Unnamed Patient"
                let patientID = doc.documentID
                let patient = DoctorPatient(id: patientID, name: name, email: patientEmail)
                
                onAddPatient(patient)
                presentationMode.wrappedValue.dismiss()
            }
    }
}
