import Foundation
import FirebaseFirestore
//import FirebaseFirestoreSwift

struct DoctorPatient: Identifiable, Codable {
    var id: String  // patient uid
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
    
    func fetchPatients() {
        let db = FirebaseManager.shared.firestore
        listener = db.collection("users").document(doctorUid).collection("patients")
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
    
    func addPatient(_ patient: DoctorPatient) {
        let db = FirebaseManager.shared.firestore
        do {
            try db.collection("users").document(doctorUid).collection("patients")
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
