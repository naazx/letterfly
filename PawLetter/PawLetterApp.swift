//
//  PawLetterApp.swift
//  PawLetter
//
//  Created by Nazar Dydyn on 27.06.2026.
//

import SwiftUI
import FirebaseCore

@main
struct PawLetterApp: App {
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
             ContentView()
           // AuthView()
        }
    }
}
