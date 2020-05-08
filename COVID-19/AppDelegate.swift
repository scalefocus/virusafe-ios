//
//  AppDelegate.swift
//  COVID-19
//
//  Created by Ivan Georgiev on 19.03.20.
//  Copyright © 2020 Upnetix AD. All rights reserved.
//

import UIKit
import UserNotifications
import CoreLocation
import AppCenter
import AppCenterAnalytics
import AppCenterCrashes
import Firebase
import IQKeyboardManager
import FirebaseMessaging
import NetworkKit
import Flex
import FontAwesome_swift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    lazy var locationManager: CLLocationManager = {
        let locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers // we want coarse location
        locationManager.allowsBackgroundLocationUpdates = true // we want it in background aswell
        locationManager.pausesLocationUpdatesAutomatically = false // no auto pause please
        locationManager.distanceFilter = 50 // user should move at least n meters
        locationManager.activityType = .fitness // we want to be gentle here
        return locationManager
    }()

    var flowManager: AppFlowManager?

    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {

        // Firebase
        FirebaseApp.configure()

        //Firebase Push Notifications
        Messaging.messaging().delegate = self

        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
        }

        return true
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        //Initialize Localizaer
        let locale = Locale(identifier: LanguageHelper.shared.savedLocale)
        Flex.shared.initialize(locale: locale,
                               enableLogging: true,
                               defaultLoggingReturn: Flex.DefaultReturnBehavior.empty)

        // App Center
        MSAppCenter.start(AppSecrets.appCenterSecret, withServices: [
            MSAnalytics.self,
            MSCrashes.self
        ])

        // Handle Keyboard
        IQKeyboardManager.shared().isEnabled = true

        // Network Auth
        APIManager.shared.authToken = TokenStore.shared.token
        APIManager.shared.refreshToken = TokenStore.shared.refreshToken
        // Network client id
        APIManager.shared.clientId = AppSecrets.apiSecret

        // Autostart if possible
        tryStartListenForLocationChanges()

        // register for notifications
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onDidReceivePushNotification(_:)),
                                               name: NSNotification.Name("PresentWebViewControllerWithPushNotification"),
                                               object: nil)

        // Allow Pro fons
        FontAwesomeConfig.usesProFonts = true

        // Init App Window
        let window = UIWindow(frame: UIScreen.main.bounds)
        self.window = window
        // init app flow
        flowManager = AppFlowManager(window: window) // !!! Force unwrap

        return true
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // !!! This is not called on ios 13+, so handle it in scene delegate too
        guard let window = window else { return }
        flowManager = AppFlowManager(window: window)
        Flex.shared.willEnterForeground()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        Flex.shared.willTerminate()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // !!! This is not called on ios 13+, so handle it in scene delegate too
        Flex.shared.didEnterBackground()
    }

    // MARK: UISceneSession Lifecycle

    @available(iOS 13.0, *)
    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
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

    // MARK: Show Notification after wakeup

    @objc
    private func onDidReceivePushNotification(_ notification: Notification) {
        let userInfo = notification.userInfo
        guard let urlString = userInfo?["url"] as? String else {
            return
        }
        // Give it some time to present screens
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            self?.flowManager?.navigateTo(step: .web(source: .notification(urlString)))
        }
    }

}

// MARK: MessagingDelegate

extension AppDelegate: MessagingDelegate {

    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        // Note: This callback is fired at each app startup and whenever a new token is generated.
        print("Firebase registration token: \(fcmToken)")
        PushTokenStore.shared.fcmToken = fcmToken
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {

        completionHandler([.alert, .badge, .sound])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {

        let applicationState = UIApplication.shared.applicationState
        let userInfo = response.notification.request.content.userInfo
        if let urlString = userInfo["url"] as? String {
            if applicationState == .active {
                // we're in the app just open it
                flowManager?.navigateTo(step: .web(source: .notification(urlString)))
            } else if applicationState == .inactive || applicationState == .background {
                // app is moving from background to actives or vice vers
                NotificationCenter.default.post(name: Notification.Name("PresentWebViewControllerWithPushNotification"),
                                                object: nil,
                                                userInfo: userInfo)
            }
        }

        completionHandler()
    }

    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {

        completionHandler(.newData)
    }
}

// MARK: UNUserNotificationCenterDelegate

extension AppDelegate: UNUserNotificationCenterDelegate { }

// MARK: CLLocationManagerDelegate

extension AppDelegate: CLLocationManagerDelegate {

    var isLocationServicesAuthorized: Bool {
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined, .restricted, .denied:
            return false
        case .authorizedAlways, .authorizedWhenInUse: // authorized is deprecated
            return true
        @unknown default:
            break
        }

        return false
    }

    func tryStartListenForLocationChanges() {
        guard CLLocationManager.locationServicesEnabled() else {
            return
        }

        guard isLocationServicesAuthorized else {
            return
        }

        locationManager.startUpdatingLocation()
        // Try to wake app if killed by the user
        locationManager.startMonitoringSignificantLocationChanges()
    }

    // we're here only because of error
    func stopListenForLocationChanges() {
        locationManager.stopUpdatingLocation()
        locationManager.stopMonitoringSignificantLocationChanges()
    }

    func requestLocationServicesAutorization() {
        locationManager.requestAlwaysAuthorization()
        // Autostart if possible
        tryStartListenForLocationChanges()
    }

    func currentLocation() -> (latitude: Double, longitude: Double)? {
        guard let location = locationManager.location else {
            return nil
        }
        return (latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .denied ||
            status == .authorizedWhenInUse ||
            status == .restricted ||
            status == .authorizedAlways {
            NotificationCenter.default.post(name: Notification.Name("didChooseLocationAccess"), object: nil)
        } else {
            // Do something
        }
    }

    // TODO: Refactor
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let dateNow = Date()
        print(locations)

        let updateInterval = RemoteConfigHelper.shared.locationIntervalMinutes
        let nextLocationUpdateTimestamp: Date =
            UserDefaults.standard.object(forKey: "nextLocationUpdateTimestamp") as? Date ?? dateNow

        if dateNow >= nextLocationUpdateTimestamp {
            guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }

            LocationRepository().sendGPSLocation(latitude: locValue.latitude,
                                                 longitude: locValue.longitude,
                                                 completion: { result in
                                                    print("\(result)")
                                                    // Do something
            })

            var components = DateComponents()
            components.setValue(updateInterval, for: .minute)

            let date: Date = Date()
            let newDate = Calendar.current.date(byAdding: components, to: date)

            UserDefaults.standard.set(newDate, forKey: "nextLocationUpdateTimestamp")
            UserDefaults.standard.synchronize()
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // TODO: handle location Error
        print("============  LOCATION MANAGER ERROR: \(error)  ============")
        stopListenForLocationChanges()
    }
}

extension String {
    /// Helpful function to access the localization from everywhere
    ///
    /// - Returns: The value in the localizations
    func localized() -> String {

        return Flex.shared.getString(key: "Common.\(self)").replacingOccurrences(of: "$s", with: "$@")

    }

}
