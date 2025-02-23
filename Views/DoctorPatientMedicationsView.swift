//
//  DoctorPatientMedicationsView.swift
//  healthapp
//
//  Created by David Santos on 2/23/25.
//


// DoctorPatientMedicationsView.swift (in Views folder)
import SwiftUI

struct DoctorPatientMedicationsView: View {
    let patient: DoctorPatient
    @StateObject private var medicationVM: MedicationViewModel
    @State private var showAddMedication = false
    
    let darkRed = Color(red: 139/255, green: 0, blue: 0)
    
    init(patient: DoctorPatient) {
        self.patient = patient
        // Initialize MedicationViewModel with the patient's UID.
        _medicationVM = StateObject(wrappedValue: MedicationViewModel(userID: patient.id))
    }
    
    var body: some View {
        VStack {
            Text("\(patient.name)'s Medications")
                .font(.largeTitle)
                .padding()
            
            if medicationVM.medications.isEmpty {
                Text("No medications found for this patient.")
                    .foregroundColor(.gray)
            } else {
                List {
                    ForEach(medicationVM.medications) { medication in
                        MedicationCard(medication: medication, darkRed: darkRed, onToggleTaken: { newState in
                            var updatedMedication = medication
                            updatedMedication.isTaken = newState
                            medicationVM.updateMedication(updatedMedication)
                        })
                    }
                    .onDelete { indexSet in
                        indexSet.forEach { index in
                            let medication = medicationVM.medications[index]
                            medicationVM.deleteMedication(medication)
                        }
                    }
                }
                .listStyle(PlainListStyle())
            }
            
            Button(action: {
                showAddMedication = true
            }) {
                Text("Add Medication")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding()
            .sheet(isPresented: $showAddMedication) {
                DoctorMedicationFormView { newMedication in
                    medicationVM.addMedication(newMedication)
                }
            }
            
            Spacer()
        }
        .navigationTitle("Patient Medications")
    }
}
