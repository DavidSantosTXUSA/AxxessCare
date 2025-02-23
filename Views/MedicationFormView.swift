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
    
    let darkRed = Color(red: 139/255, green: 0, blue: 0) // Dashboard Matching Color
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("MEDICATION DETAILS").foregroundColor(darkRed).bold()) {
                    TextField("Medication Name", text: $name)
                        .padding(8)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    
                    TextField("Dosage (e.g., 10mg)", text: $dosage)
                        .padding(8)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    
                    Picker("Frequency", selection: $frequency) {
                        Text("Daily").tag("Daily")
                        Text("Every 8 hours").tag("Every 8 hours")
                        Text("Every 12 hours").tag("Every 12 hours")
                    }
                    .pickerStyle(MenuPickerStyle())
                    
                    Picker("Time of Day", selection: $timeOfDay) {
                        Text("Morning").tag("Morning")
                        Text("Afternoon").tag("Afternoon")
                        Text("Evening").tag("Evening")
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                Section(header: Text("DURATION").foregroundColor(darkRed).bold()) {
                    DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                        .datePickerStyle(CompactDatePickerStyle())
                    DatePicker("End Date", selection: $endDate, displayedComponents: .date)
                        .datePickerStyle(CompactDatePickerStyle())
                }
                
                Section(header: Text("PRESCRIBER INFO").foregroundColor(darkRed).bold()) {
                    TextField("Prescribed By (Doctor's Name)", text: $prescribedBy)
                        .padding(8)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
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
            }.foregroundColor(darkRed))
        }
    }
}

