//
//  FirebaseManager.swift
//  healthapp
//
//  Created by David Santos on 2/22/25.
//


import Foundation
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore

class FirebaseManager: ObservableObject {
    static let shared = FirebaseManager()

    let auth: Auth
    let firestore: Firestore

    private init() {
        //FirebaseApp.configure()
        self.auth = Auth.auth()
        self.firestore = Firestore.firestore()
    }
}
