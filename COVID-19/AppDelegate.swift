//
//  AppDelegate.swift
//  COVID-19
//
//  Created by Ivan Georgiev on 19.03.20.
//  Copyright © 2020 Upnetix AD. All rights reserved.
//

import UIKit
import UserNotifications
import AppCenter
import AppCenterAnalytics
import AppCenterCrashes
import Firebase
import IQKeyboardManager
import FirebaseMessaging
import NetworkKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var locationManager: CLLocationManager?
    
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        // Firebase
        FirebaseApp.configure()
        
        Messaging.messaging().delegate = self
        
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
        }
        
        return true
    }

    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // App Center
        MSAppCenter.start("e78845ce-5af8-49bc-9cf4-35bcb984fdc5", withServices: [
            MSAnalytics.self,
            MSCrashes.self
        ])

        // Handle Keyboard
        IQKeyboardManager.shared().isEnabled = true

        // Network Auth
        APIManager.shared.authToken = TokenStore.shared.token

        // Init App Window
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()
        window?.makeKeyAndVisible()
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

}

extension AppDelegate: MessagingDelegate {
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
      print("Firebase registration token: \(fcmToken)")

      let dataDict:[String: String] = ["token": fcmToken]
      NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
      // TODO: If necessary send token to application server.
      // Note: This callback is fired at each app startup and whenever a new token is generated.
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        completionHandler([.alert, .badge, .sound])
    }
    
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let applicationState = UIApplication.shared.applicationState
        
        if applicationState == .active ||  applicationState == .inactive || applicationState == .background {
            let userInfo = response.notification.request.content.userInfo
            if let urlData = userInfo["url"] {
                if let urlString = urlData as? String {
                    WebViewController.show(with: .notification(urlString))
                }
//                if let url = URL(string: urlData as! String), UIApplication.shared.canOpenURL(url) {
//                    if #available(iOS 10.0, *) {
//                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
//                    } else {
//                        UIApplication.shared.openURL(url)
//                    }
//                }
            }
        }
        
        
        completionHandler()
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {

        completionHandler(.newData)
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    
}

extension AppDelegate: CLLocationManagerDelegate {
    
    func requestLocationServicesAutorization() {
        locationManager = CLLocationManager()
        locationManager?.requestAlwaysAuthorization()

        if CLLocationManager.locationServicesEnabled() {
            locationManager?.delegate = self
            locationManager?.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager?.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .denied ||
           status == .authorizedWhenInUse ||
           status == .restricted ||
           status == .authorizedAlways {
            NotificationCenter.default.post(name: Notification.Name("didChooseLocationAccess"), object: nil)
        } else {
            
        }
    }

    // TODO: Refactor
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let dateNow = Date()

        let updateInterval = RemoteConfig.remoteConfig().configValue(forKey: "ios_location_interval_in_mins").numberValue?.intValue
        let nextLocationUpdateTimestamp: Date =
            UserDefaults.standard.object(forKey: "nextLocationUpdateTimestamp") as? Date ?? dateNow

        if dateNow >= nextLocationUpdateTimestamp {
            guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }


            let decoder = JWTDecoder()
            let token = TokenStore.shared.token!
            let jwtBody: [String: Any] = decoder.decode(jwtToken: token)
            let phoneNumber = jwtBody["phoneNumber"] as! String

            LocationRepository().sendGPSLocation(latitude: locValue.latitude,
                                                 longitude: locValue.longitude,
                                                 for: phoneNumber,
                                                 completion: { result in
                                                    print("\(result)")
            })

            var components = DateComponents()
            components.setValue((updateInterval ?? 10) / 60, for: .hour)

            let date: Date = Date()
            let newDate = Calendar.current.date(byAdding: components, to: date)

            UserDefaults.standard.set(newDate, forKey:"nextLocationUpdateTimestamp")
            UserDefaults.standard.synchronize()
        }
    }
}
