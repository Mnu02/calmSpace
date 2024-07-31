//
//  NoAccountView.swift
//  calmSpace
//
//  Created by Mnumzana Franklin Moyo on 7/10/24.
//

import SwiftUI
import Firebase
import FirebaseCore

struct NoAccountView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var username: String = ""
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var navigateToHome: Bool = false

    var body: some View {
        
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.backgroundColor, Color.purple.opacity(0.3)]), startPoint: .bottom, endPoint: .top)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                //MARK: Logo
                Image("logo")
                
                Spacer()
                    .frame(height: 50)
                
                //MARK: Username
                VStack (alignment: .leading) {
                    Text("Username")
                        .font(.subheadline)
                        .foregroundColor(.black)
                    TextField ("Enter username", text:$username)
                        .padding()
                        .background(.white)
                        .frame(width: 350)
                        .autocorrectionDisabled()
                        .autocapitalization(.none)
                        .cornerRadius(10)
                }
                
                //MARK: Email address
                VStack (alignment: .leading) {
                    Text("Email Address")
                        .font(.subheadline)
                        .foregroundColor(.black)
                    TextField ("Enter email", text:$email)
                        .padding()
                        .background(.white)
                        .frame(width: 350)
                        .autocorrectionDisabled()
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                        .cornerRadius(10)
                }
                
                //MARK: Password
                VStack (alignment: .leading) {
                    Text("Password")
                        .font(.subheadline)
                        .foregroundColor(.black)
                    SecureField("Password", text: $password)
                        .padding()
                        .background(.white)
                        .cornerRadius(10)
                        .frame(width: 350)
                }
                
                VStack (alignment: .leading) {
                    //MARK: Confirm password
                    Text("Confirm Password")
                        .font(.subheadline)
                        .foregroundColor(.black)
                    SecureField("Confirm Password", text: $confirmPassword)
                        .padding()
                        .background(.white)
                        .cornerRadius(10)
                        .frame(width: 350)
                }
                
                Button(action: signUp) {
                    Text("Sign Up")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 300, height: 50)
                        .background(Color.deepPurple)
                        .cornerRadius(10)
                }
                .padding(.top, 40)
                .alert(isPresented: $showAlert ) {
                    Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                }
            }
        }
        .fullScreenCover(isPresented: $navigateToHome) {
            ManyChatsView()
        }
    }
    
    func signUp() {
        guard password == confirmPassword else{
            alertMessage = "Passwords do not match"
            showAlert = true
            return
        }
        Auth.auth().createUser(withEmail: email, password: password) {
            authResult, error in            
            DispatchQueue.main.async {
                if let error = error {
                    alertMessage = error.localizedDescription
                    showAlert = true
                } else {
                    guard let user = authResult?.user else {
                        return
                    }
                    let db = Firestore.firestore()
                    db.collection("users").document(user.uid).setData([
                        "username" : username,
                        "email" : email,
                        "password": password
                    ]) {
                        error in
                        if let error = error {
                            alertMessage = "Error saving user information: \(error.localizedDescription)"
                            showAlert = true
                        } else {
                            navigateToHome = true
                        }
                    }
                    navigateToHome = true
                }
            }
        }
    }
}

#Preview {
    NoAccountView()
}
