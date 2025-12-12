//
//  OuickShop_by_MystoreApp.swift
//  OuickShop by Mystore
//
//  Created by Purna Jear on 05/05/25.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth
import UserNotifications

// Firebase App Delegate
class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        print("🚀 Configuring Firebase...")
        
        // Configure Firebase first
        FirebaseApp.configure()
        
        // Set up notifications for phone auth
        UNUserNotificationCenter.current().delegate = self
        
        // Request notification permissions for phone auth (required for real device)
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            print("📱 Notification permission granted: \(granted)")
            if let error = error {
                print("❌ Notification permission error: \(error)")
            }
            
            DispatchQueue.main.async {
                if granted {
                    application.registerForRemoteNotifications()
                }
            }
        }
        
        // Configure Firebase Auth for production use
        #if DEBUG
        print("🔧 Debug mode - Firebase Auth configured for development")
        #else
        print("🚀 Production mode - Firebase Auth configured for production")
        #endif
        
        print("✅ Firebase configured successfully")
        return true
    }
    
    // Handle APNs token for Firebase (CRITICAL for phone auth on real device)
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("📱 APNs token received successfully - length: \(deviceToken.count) bytes")
        
        // Set the APNs token for Firebase Auth with proper type for development
        #if DEBUG
        Auth.auth().setAPNSToken(deviceToken, type: .sandbox)
        print("🔧 Set APNs token for development/sandbox environment")
        #else
        Auth.auth().setAPNSToken(deviceToken, type: .prod)
        print("🚀 Set APNs token for production environment")
        #endif
        
        // Convert token to string for logging (first 8 chars only for security)
        let tokenParts = deviceToken.map { String(format: "%02.2hhx", $0) }
        let tokenString = tokenParts.joined()
        print("🔑 APNs token (first 16 chars): \(String(tokenString.prefix(16)))...")
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("❌ Failed to register for remote notifications: \(error.localizedDescription)")
        print("🔍 Full error: \(error)")
        print("💡 Phone authentication will not work without APNs - use email login instead")
        
        // Check specific error conditions
        if error.localizedDescription.contains("no valid aps-environment") {
            print("🚨 APNs environment not configured in entitlements")
        }
        if error.localizedDescription.contains("Push Notifications") {
            print("🚨 Push Notifications capability not enabled in project")
        }
    }
    
    // Handle silent push notifications for Firebase Auth
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        // Check if this is a Firebase Auth notification
        if Auth.auth().canHandleNotification(userInfo) {
            completionHandler(.noData)
            return
        }
        
        completionHandler(.newData)
    }
    
    // Handle notification responses
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        if #available(iOS 14.0, *) {
            completionHandler([.banner, .list, .sound])
        } else {
            completionHandler([.alert, .sound])
        }
    }
}

@main
struct OuickShop_by_MystoreApp: App {
    // Register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    // State objects for view models (shared across the app)
    @StateObject private var homeViewModel = HomeViewModel()
    @StateObject private var cartViewModel = CartViewModel()
    @StateObject private var userViewModel = UserViewModel()
    
    init() {
        // Print for debugging startup
        print("App starting - initializing view models")
    }
    
    var body: some Scene {
        WindowGroup {
            SplashView()
                .environmentObject(homeViewModel)
                .environmentObject(cartViewModel)
                .environmentObject(userViewModel)
                .accentColor(Color.accentColor)
                .onAppear {
                    // Set app-wide appearance
                    UIScrollView.appearance().bounces = true
                    UITableView.appearance().showsVerticalScrollIndicator = false
                    
                    // Print debugging info
                    print("SplashView appeared")
                    
                    // Reduce the simulator scaling for development
                    #if DEBUG
                    // For Simulator: Command+1 (100%), Command+2 (75%), Command+3 (50%), etc.
                    #endif
                }
        }
    }
}
