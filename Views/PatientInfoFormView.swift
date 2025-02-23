import SwiftUI

struct PatientInfoFormView: View {
    @EnvironmentObject var patientInfoVM: PatientInfoViewModel
    @State private var name = ""
    @State private var age = ""
    @State private var gender = ""
    @State private var contactNumber = ""
    @State private var isSaved = false
    @State private var showError = false

    var body: some View {
        Form {
            Section(header: Text("Basic Information")) {
                TextField("Name", text: $name)
                TextField("Age", text: $age)
                    .keyboardType(.numberPad)
                TextField("Gender", text: $gender)
                TextField("Contact Number", text: $contactNumber)
                    .keyboardType(.phonePad)
            }

            Button(action: {
                if name.isEmpty || age.isEmpty || gender.isEmpty || contactNumber.isEmpty {
                    showError = true
                    return
                }
                
                let info = Patient(name: name, age: age, gender: gender, contactNumber: contactNumber, email: "N/A")  // Ensure this struct matches your Firestore model
                
                patientInfoVM.patientInfo = info  // Now this should work

                isSaved = true
            }) {
                Text("Save Information")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(10)
            }

            if showError {
                Text("All fields must be filled!")
                    .foregroundColor(.red)
            }

            if isSaved {
                Text("Information Saved Successfully!")
                    .foregroundColor(.green)
            }
        }
        .navigationTitle("Enter Your Info")
    }
}

