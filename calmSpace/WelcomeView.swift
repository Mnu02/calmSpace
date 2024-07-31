//
//  WelcomeView.swift
//  calmSpace
//
//  Created by Mnumzana Franklin Moyo on 7/10/24.
//

import SwiftUI

struct WelcomeView: View {
    var body: some View {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color.backgroundColor, Color.purple.opacity(0.3)]), startPoint: .bottom, endPoint: .top)
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    //MARK: Logo
                    Image("logo")
                    
                    Spacer()
                        .frame(height: 250)
                    
                    //MARK: Two buttons
                    NavigationLink(destination : NoAccountView()){
                        Text("I'm new here")
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .frame(width: 300, height: 50)
                            .background(Color.deepPurple)
                            .cornerRadius(10)
                    }
                    .frame(width: 300, height: 50)
                    .padding()

                    NavigationLink(destination : HasAccountView()){
                        Text("I have an account")
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .frame(width: 300, height: 50)
                            .background(Color.deepPurple)
                            .cornerRadius(10)
                    }
                }
            }
        }
    }

#Preview {
    WelcomeView()
}