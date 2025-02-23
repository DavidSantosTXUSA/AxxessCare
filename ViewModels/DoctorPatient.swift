//
//  DoctorNetworkViewModel.swift
//  healthapp
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

struct DoctorPatient: Identifiable, Codable {
    var id: String  // Patient UID (matches the document ID)
    var name: String
    var email: String
}

class DoctorNetworkViewModel: ObservableObject {
    @Published var patients: [DoctorPatient] = []
    private var listener: ListenerRegistration?
    let doctorUid: String
    
    init(doctorUid: String) {
        self.doctorUid = doctorUid
        fetchPatients()
    }
    
    // Listen to doctor’s subcollection: users/{doctorUid}/patients
    func fetchPatients() {
        guard !doctorUid.isEmpty else {
            print("DoctorNetworkViewModel: doctorUid is empty, skipping fetch.")
            return
        }
        let db = FirebaseManager.shared.firestore
        listener = db.collection("users")
            .document(doctorUid)
            .collection("patients")
            .addSnapshotListener { [weak self] snapshot, error in
                if let error = error {
                    print("Error fetching doctor network: \(error.localizedDescription)")
                    return
                }
                guard let documents = snapshot?.documents else { return }
                self?.patients = documents.compactMap { doc in
                    try? doc.data(as: DoctorPatient.self)
                }
            }
    }
    
    // Soft-delete: remove patient from doctor’s subcollection
    func removePatient(_ patient: DoctorPatient) {
        let db = FirebaseManager.shared.firestore
        db.collection("users")
            .document(doctorUid)
            .collection("patients")
            .document(patient.id)
            .delete { error in
                if let error = error {
                    print("Error deleting patient: \(error.localizedDescription)")
                } else {
                    print("Patient \(patient.name) removed from doctor's network.")
                }
            }
    }
    
    // Optional: Add a patient (used by AddPatientView)
    func addPatient(_ patient: DoctorPatient) {
        let db = FirebaseManager.shared.firestore
        do {
            try db.collection("users")
                .document(doctorUid)
                .collection("patients")
                .document(patient.id)
                .setData(from: patient)
        } catch {
            print("Error adding patient: \(error)")
        }
    }
    
    deinit {
        listener?.remove()
    }
}
