// Patient Medications View

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
            // HEADER: Patient Name & Title
            HStack {
                VStack(alignment: .leading) {
                    Text("Patient Medications")
                        .font(.title3)
                        .foregroundColor(.gray)
                    
                    Text("\(patient.name)'s Medications")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(darkRed)
                }
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 10)
            
            // MEDICATION LIST
            if medicationVM.medications.isEmpty {
                Text("No medications found for this patient.")
                    .foregroundColor(.gray)
                    .padding(.top, 10)
            } else {
                ScrollView {
                    VStack(spacing: 10) {
                        ForEach(medicationVM.medications) { medication in
                            MedicationCard(medication: medication, darkRed: darkRed, onToggleTaken: { newState in
                                var updatedMedication = medication
                                updatedMedication.isTaken = newState
                                medicationVM.updateMedication(updatedMedication)
                            })
                        }
                    }
                    .padding(.horizontal)
                }
            }
            
            Spacer()
            
            // ADD MEDICATION BUTTON
            Button(action: {
                showAddMedication = true
            }) {
                Text("Add Medication")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(darkRed)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .shadow(radius: 3)
            }
            .padding()
            .sheet(isPresented: $showAddMedication) {
                DoctorMedicationFormView { newMedication in
                    medicationVM.addMedication(newMedication)
                }
            }
        }
        .navigationBarBackButtonHidden(false)
    }
}
