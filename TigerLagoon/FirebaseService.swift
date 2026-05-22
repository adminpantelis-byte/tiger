import SwiftUI
import UIKit
import UserNotifications

#if canImport(FirebaseAnalytics)
import FirebaseAnalytics
#endif
#if canImport(FirebaseCore)
import FirebaseCore
#endif
#if canImport(FirebaseMessaging)
import FirebaseMessaging
#endif

final class TigerLagoonAppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        configureFirebaseIfAvailable()
        configurePushNotifications(application)
        return true
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        #if canImport(FirebaseMessaging)
        Messaging.messaging().apnsToken = deviceToken
        #endif
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        #if DEBUG
        print("Tiger Lagoon push registration failed: \(error.localizedDescription)")
        #endif
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        [.banner, .sound, .badge]
    }

    private func configureFirebaseIfAvailable() {
        #if canImport(FirebaseCore)
        guard FirebaseApp.app() == nil else { return }

        if let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
           let options = FirebaseOptions(contentsOfFile: path) {
            FirebaseApp.configure(options: options)
            #if canImport(FirebaseAnalytics)
            Analytics.logEvent(AnalyticsEventAppOpen, parameters: nil)
            #endif
        } else {
            #if DEBUG
            print("GoogleService-Info.plist is missing. Firebase is not configured.")
            #endif
        }
        #endif
    }

    private func configurePushNotifications(_ application: UIApplication) {
        UNUserNotificationCenter.current().delegate = self

        Task { @MainActor in
            do {
                let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
                guard granted else { return }
                application.registerForRemoteNotifications()
            } catch {
                #if DEBUG
                print("Tiger Lagoon notification permission failed: \(error.localizedDescription)")
                #endif
            }
        }

        #if canImport(FirebaseMessaging)
        Messaging.messaging().delegate = self
        #endif
    }
}

#if canImport(FirebaseMessaging)
extension TigerLagoonAppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        #if DEBUG
        if let fcmToken {
            print("Tiger Lagoon FCM token: \(fcmToken)")
        }
        #endif
    }
}
#endif
