//
//  AuthManager.swift
//  calmSpace
//
//  Created by Mnumzana Franklin Moyo on 8/21/24.
//

import Foundation
import SwiftUI
import FirebaseAuth

class AuthManager: ObservableObject {
    @Published var isLoggedIn: Bool = false
    @Published var currentUser: User?
    @Published var needsVerification: Bool = true

    init() {
        self.currentUser = Auth.auth().currentUser
        self.isLoggedIn = self.currentUser != nil
        self.needsVerification = true
        Auth.auth().addStateDidChangeListener { _, user in
            self.currentUser = user
            self.isLoggedIn = user != nil
            if user != nil {
                self.needsVerification = false  // Skip verification after first successful login
            }
        }
    }

    func signOut() throws {
        try Auth.auth().signOut()
        self.isLoggedIn = false
        self.currentUser = nil
        self.needsVerification = true
    }
}

