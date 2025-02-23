import Foundation

class PatientInfoViewModel: ObservableObject {
    @Published var patientInfo: PatientInfo? {
        didSet {
            savePatientInfo()
        }
    }

    init() {
        loadPatientInfo()
    }

    func savePatientInfo() {
        do {
            let encoded = try JSONEncoder().encode(patientInfo)
            UserDefaults.standard.set(encoded, forKey: "SavedPatientInfo")
        } catch {
            print("Failed to save patient info: \(error)")
        }
    }

    func loadPatientInfo() {
        guard let savedData = UserDefaults.standard.data(forKey: "SavedPatientInfo") else {
            print("No saved data found")
            return
        }

        do {
            let decodedInfo = try JSONDecoder().decode(PatientInfo.self, from: savedData)
            self.patientInfo = decodedInfo
        } catch {
            print("Failed to load patient info: \(error)")
        }
    }
}
