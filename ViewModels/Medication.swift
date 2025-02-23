import Foundation

struct Medication: Identifiable, Codable {
    let id = UUID()
    var name: String
    var dosage: String
    var frequency: String // Example: "Daily", "Every 8 hours"
    var startDate: Date
    var endDate: Date
    var timeOfDay: String // Example: "Morning", "Evening"
    var prescribedBy: String // Doctor's Name or ID
}
