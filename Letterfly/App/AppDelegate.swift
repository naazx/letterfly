//
//  AppDelegate.swift
//  PawLetter
//
//  Created by Nazar Dydyn on 25.08.2026.
//

import UIKit
import FirebaseCore
import FirebaseMessaging

class AppDelegate: NSObject, UIApplicationDelegate, MessagingDelegate {
    var pushService: PushNotificationService?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        print("AppDelegate launched")
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        return true
    }

    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        print("APNs device token received")
        Messaging.messaging().apnsToken = deviceToken
    }

    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("FCM token received: \(fcmToken ?? "nil")")
        pushService?.fcmToken = fcmToken
    }
}
