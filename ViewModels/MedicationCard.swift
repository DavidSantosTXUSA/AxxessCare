
import SwiftUI

struct MedicationCard: View {
    let medication: Medication
    let darkRed: Color
    var onToggleTaken: (Bool) -> Void
    @State private var isTaken: Bool
    
    init(medication: Medication, darkRed: Color, onToggleTaken: @escaping (Bool) -> Void) {
        self.medication = medication
        self.darkRed = darkRed
        self.onToggleTaken = onToggleTaken
        _isTaken = State(initialValue: medication.isTaken)
    }
    
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
                isTaken.toggle()
                onToggleTaken(isTaken)
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
