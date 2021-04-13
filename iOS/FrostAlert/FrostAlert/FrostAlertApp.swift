//
//  FrostAlertApp.swift
//  FrostAlert
//
//  Created by Andrew James on 4/11/21.
//

import SwiftUI
import UIKit // needed for App Delegate functionality to configure Firebase
import Firebase


@main
struct FrostAlertApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate // confgure Firebase on startup
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure() // sets up firebase configureation
        return true
    }
}
