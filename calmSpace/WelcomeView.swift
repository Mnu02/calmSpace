//
//  WelcomeView.swift
//  calmSpace
//
//  Created by Mnumzana Franklin Moyo on 7/10/24.
//

import SwiftUI
import FirebaseAuth
import GoogleSignIn
import GoogleSignInSwift
import FirebaseCore

struct WelcomeView: View {
    @State private var navigateToManyChats: Bool = false
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color.backgroundColor, Color.purple.opacity(0.3)]), startPoint: .bottom, endPoint: .top)
                    .edgesIgnoringSafeArea(.all)

                VStack {
                    // MARK: Logo
                    Image("logo")

                    Spacer()
                        .frame(height: 250)

                    // MARK: Google Sign-In Button
                    Button(action: {
                        signInWithGoogle()
                    }) {
                        Text("Verify me")
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .frame(width: 300, height: 50)
                            .background(Color.deepPurple)
                            .cornerRadius(10)
                    }
                    .frame(width: 300, height: 50)
                    .padding()
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Sign-In Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
            .navigationDestination(isPresented: $navigateToManyChats) {
                ManyChatsView()
            }
        }
    }

    private func signInWithGoogle() {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            alertMessage = "Missing Google Client ID"
            showAlert = true
            return
        }

        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let presentingViewController = windowScene.windows.first?.rootViewController else {
            alertMessage = "Unable to find a valid presenting view controller"
            showAlert = true
            return
        }

        GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController) { result, error in
            if let error = error {
                alertMessage = "Error signing in: \(error.localizedDescription)"
                showAlert = true
                return
            }

            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString else {
                alertMessage = "Error signing in: Unable to get user ID token"
                showAlert = true
                return
            }

            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)

            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    alertMessage = "Firebase sign-in error: \(error.localizedDescription)"
                    showAlert = true
                } else {
                    // Ensure the user is signed in and then navigate
                    if Auth.auth().currentUser != nil {
                        print("User is signed in: \(String(describing: Auth.auth().currentUser?.uid))")
                        navigateToManyChats = true
                    } else {
                        alertMessage = "Sign-in succeeded, but no user found."
                        showAlert = true
                    }
                }
            }
        }
    }
}

#Preview {
    WelcomeView()
}
