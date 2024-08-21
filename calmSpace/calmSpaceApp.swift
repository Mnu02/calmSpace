//
//  calmSpaceApp.swift
//  calmSpace
//
//  Created by Mnumzana Franklin Moyo on 7/10/24.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth
import GoogleSignIn


class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
      return GIDSignIn.sharedInstance.handle(url)
    }
}

@main
struct calmSpaceApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var authManager = AuthManager()
    
    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            if authManager.needsVerification {
                WelcomeView()
                    .environmentObject(authManager)
            } else if authManager.isLoggedIn {
                ManyChatsView()
                    .environmentObject(authManager)
            } else {
                WelcomeView()
                    .environmentObject(authManager)
            }
        }
    }
}
