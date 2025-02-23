import SwiftUI

struct PatientProfileView: View {
    @EnvironmentObject var patientInfoVM: PatientInfoViewModel

    var body: some View {
        VStack {
            if let info = patientInfoVM.patientInfo {
                Text("Patient Profile")
                    .font(.largeTitle)
                    .padding()

                Text("Name: \(info.name)")
                Text("Age: \(info.age)")
                Text("Gender: \(info.gender)")
                Text("Contact Number: \(info.contactNumber)")
            } else {
                Text("No information available. Please fill out the form.")
                    .foregroundColor(.gray)
            }
        }
        .navigationTitle("Profile")
        .padding()
    }
}
