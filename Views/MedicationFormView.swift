import SwiftUI

struct MedicationFormView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var name = ""
    @State private var dosage = ""
    @State private var frequency = "Daily"
    @State private var startDate = Date()
    @State private var endDate = Date()
    @State private var timeOfDay = "Morning"
    @State private var prescribedBy = ""
    
    var onSave: (Medication) -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Medication Details")) {
                    TextField("Medication Name", text: $name)
                    TextField("Dosage (e.g., 10mg)", text: $dosage)
                    Picker("Frequency", selection: $frequency) {
                        Text("Daily").tag("Daily")
                        Text("Every 8 hours").tag("Every 8 hours")
                        Text("Every 12 hours").tag("Every 12 hours")
                    }
                    Picker("Time of Day", selection: $timeOfDay) {
                        Text("Morning").tag("Morning")
                        Text("Afternoon").tag("Afternoon")
                        Text("Evening").tag("Evening")
                    }
                }
                
                Section(header: Text("Duration")) {
                    DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                    DatePicker("End Date", selection: $endDate, displayedComponents: .date)
                }
                
                Section(header: Text("Prescriber Info")) {
                    TextField("Prescribed By (Doctor's Name)", text: $prescribedBy)
                }
            }
            .navigationTitle("Add Medication")
            .navigationBarItems(trailing: Button("Save") {
                let newMedication = Medication(
                    name: name,
                    dosage: dosage,
                    frequency: frequency,
                    startDate: startDate,
                    endDate: endDate,
                    timeOfDay: timeOfDay,
                    prescribedBy: prescribedBy
                )
                onSave(newMedication)
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

