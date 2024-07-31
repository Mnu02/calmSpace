//
//  HasAccountView.swift
//  calmSpace
//
//  Created by Mnumzana Franklin Moyo on 7/10/24.
//

import SwiftUI
import FirebaseAuth
import FirebaseCore

struct HasAccountView: View {
    
    @State private var email: String = ""
    @State private var password: String = ""
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
                    .frame(height: 90)
                
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
                .frame(width: 350)
                
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
                .frame(width: 350)
                
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
                .frame(width: 350)
                
                //MARK: Sign In
                Button(action: signIn) {
                    Text("Sign In")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 300, height: 50)
                        .background(Color.deepPurple)
                        .cornerRadius(10)
                }
                .padding(.top, 40)
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                }
            }
            .fullScreenCover(isPresented : $navigateToHome) {
                ManyChatsView()
            }
        }
    }
    
    func signIn() {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            DispatchQueue.main.async {
                if let error = error {
                    alertMessage = error.localizedDescription
                    showAlert = true
                } else {
                    alertMessage = "Sign-in successful!"
                    navigateToHome = true
                }
            }
        }
    }
}

#Preview {
    HasAccountView()
}
