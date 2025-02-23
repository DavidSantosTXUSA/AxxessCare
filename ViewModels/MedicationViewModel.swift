import Foundation
import FirebaseFirestore
//import FirebaseFirestoreSwift
import FirebaseAuth

class MedicationViewModel: ObservableObject {
    @Published var medications: [Medication] = []
    private var listener: ListenerRegistration?
    let userID: String
    
    init(userID: String) {
        self.userID = userID
        guard !userID.isEmpty else {
                    print("⚠️ MedicationViewModel: userID is empty—skipping Firestore fetch.")
                    return
                }
        fetchMedications()
    }
    
    func fetchMedications() {
        guard !userID.isEmpty else { return }
        let db = FirebaseManager.shared.firestore
        listener = db.collection("users").document(userID).collection("medications")
            .addSnapshotListener { [weak self] snapshot, error in
                if let error = error {
                    print("Error fetching medications: \(error.localizedDescription)")
                    return
                }
                guard let documents = snapshot?.documents else { return }
                self?.medications = documents.compactMap { doc in
                    try? doc.data(as: Medication.self)
                }
            }
    }
    
    func updateMedication(_ medication: Medication) {
        let db = FirebaseManager.shared.firestore
        do {
            try db.collection("users").document(userID).collection("medications")
                .document(medication.id.uuidString)
                .setData(from: medication)
        } catch {
            print("Error updating medication: \(error)")
        }
    }
    
    func addMedication(_ medication: Medication) {
        let db = FirebaseManager.shared.firestore
        do {
            try db.collection("users").document(userID).collection("medications")
                .document(medication.id.uuidString)
                .setData(from: medication)
        } catch {
            print("Error adding medication: \(error)")
        }
    }
    
    func deleteMedication(_ medication: Medication) {
        let db = FirebaseManager.shared.firestore
        db.collection("users").document(userID).collection("medications")
            .document(medication.id.uuidString)
            .delete { error in
                if let error = error {
                    print("Error deleting medication: \(error)")
                }
            }
    }
    
    deinit {
        listener?.remove()
    }
}
