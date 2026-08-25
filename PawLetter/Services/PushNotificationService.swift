//
//  PushNotificationService.swift
//  PawLetter
//
//  Created by Nazar Dydyn on 25.08.2026.
//

import Foundation
import SwiftUI
import FirebaseMessaging
import FirebaseFirestore
import UserNotifications

@Observable
class PushNotificationService: NSObject {
    var fcmToken: String?

    func requestPermission() async -> Bool {
        let center = UNUserNotificationCenter.current()
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            if granted {
                await MainActor.run {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
            return granted
        } catch {
            print("Push permission error: \(error)")
            return false
        }
    }

    func saveFCMToken(uid: String) async {
        guard let fcmToken else { return }
        do {
            try await Firestore.firestore()
                .collection("users")
                .document(uid)
                .updateData(["fcmToken": fcmToken])
        } catch {
            print("Failed to save FCM token: \(error)")
        }
    }
}
