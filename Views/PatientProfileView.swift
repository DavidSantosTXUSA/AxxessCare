import SwiftUI

struct PatientProfileView: View {
    @ObservedObject var viewModel = PatientInfoViewModel()

    var body: some View {
        VStack(spacing: 20) {
            Text("Patient Profile")
                .font(.largeTitle)
                .bold()
                .foregroundColor(Color(red: 139/255, green: 0, blue: 0))

            VStack(alignment: .leading, spacing: 10) {
                if let patient = viewModel.patientInfo {
                    Text("Name: \(patient.name)")
                    Text("Age: \(patient.age)")
                    Text("Gender: \(patient.gender)")
                    Text("Contact: \(patient.contactNumber)")
                    Text("Email: \(patient.email)")
                } else {
                    Text("Loading profile...")
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(radius: 3)
            .padding(.horizontal)

            Spacer()
        }
        .onAppear {
            viewModel.fetchPatientInfo()
        }
    }
}

