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

struct AppViewRouter: Hashable, Equatable {
    enum Route: Hashable, Equatable {
        case manyChats
        case welcome
    }

    var route: Route
}

struct WelcomeView: View {
    @State private var path: [AppViewRouter] = []
    @State private var isSigningIn: Bool = false

    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color.backgroundColor, Color.purple.opacity(0.3)]), startPoint: .bottom, endPoint: .top)
                    .edgesIgnoringSafeArea(.all)

                VStack {
                    // MARK: Logo
                    Image("logo")

                    Spacer()
                        .frame(height: 250)

                    // MARK: Two buttons
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

//                    NavigationLink(destination: HasAccountView()) {
//                        Text("I have an account")
//                            .font(.subheadline)
//                            .foregroundColor(.white)
//                            .frame(width: 300, height: 50)
//                            .background(Color.deepPurple)
//                            .cornerRadius(10)
//                    }
                }
            }
            .alert(isPresented: $isSigningIn) {
                Alert(title: Text("Signing In..."), message: Text("Please wait while we sign you in with Google."), dismissButton: .default(Text("OK")))
            }
        }
        .navigationDestination(for: AppViewRouter.self) { route in
            switch route.route {
            case .manyChats:
                ManyChatsView()
            case .welcome:
                WelcomeView()
            }
        }
    }

    private func signInWithGoogle() {
            guard let clientID = FirebaseApp.app()?.options.clientID else { return }

            let config = GIDConfiguration(clientID: clientID)
            GIDSignIn.sharedInstance.configuration = config

            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let presentingViewController = windowScene.windows.first?.rootViewController else {
                return
            }

            GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController) { result, error in
                if let error = error {
                    print("Error signing in: \(error.localizedDescription)")
                    return
                }

                guard let user = result?.user,
                      let idToken = user.idToken?.tokenString else {
                    return
                }

                let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)

                Auth.auth().signIn(with: credential) { authResult, error in
                    if let error = error {
                        print("Firebase sign-in error: \(error.localizedDescription)")
                    } else {
                        print("User is signed in")
                        // Navigate to ManyChatsView here
                        path.append(AppViewRouter(route: .manyChats))
                    }
                }
            }
        }
    }

#Preview {
    WelcomeView()
}
