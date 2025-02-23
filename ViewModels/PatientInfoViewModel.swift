import FirebaseFirestore
import FirebaseAuth

class PatientInfoViewModel: ObservableObject {
    @Published var patientInfo: Patient?

    func fetchPatientInfo() {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        let userRef = Firestore.firestore().collection("users").document(uid)
        userRef.getDocument { document, error in
            if let document = document, document.exists {
                let data = document.data()
                self.patientInfo = Patient(
                    name: data?["name"] as? String ?? "N/A",
                    age: (data?["age"] as? Int)?.description ?? "N/A", // Convert age to String safely
                    gender: data?["gender"] as? String ?? "N/A",
                    contactNumber: data?["contactNumber"] as? String ?? "N/A",
                    email: data?["email"] as? String ?? "N/A"  // Add this to match the struct
                )
            }
        }
    }
}

// **Struct for Patient**
struct Patient: Codable {
    var name: String
    var age: String  // Changed to String to match Firebase data type
    var gender: String
    var contactNumber: String
    var email: String  // Added missing email property
}

