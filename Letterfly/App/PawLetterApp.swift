//
//  PawLetterApp.swift
//  PawLetter
//
//  Created by Nazar Dydyn on 27.06.2026.
//

import GoogleSignIn
import SwiftUI
import FirebaseCore

@main
struct PawLetterApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State private var pushService = PushNotificationService()

    var body: some Scene {
        WindowGroup {
             ContentView()
                .environment(pushService)
                .onOpenURL { url in
                    GIDSignIn.sharedInstance.handle(url)
                }
                .onAppear {
                    appDelegate.pushService = pushService
                }
        }
    }
}
