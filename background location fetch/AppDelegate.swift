//
//  AppDelegate.swift
//  background location fetch
//
//  Created by VinBrain on 17/11/2021.
//

import UIKit
import CoreLocation
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {
    
    let locationManager = CLLocationManager()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        print("LASTTIMECALLED \(UserDefaults.standard.value(forKey: "LASTTIMECALLED"))")
        UNUserNotificationCenter.current().delegate = self
        let manager = LocalNotificationManager()
        manager.notifications = []
        
        manager.schedule()

        locationManager.requestAlwaysAuthorization()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.startUpdatingLocation()
        locationManager.startMonitoringSignificantLocationChanges()
        
        if launchOptions?[UIApplication.LaunchOptionsKey.location] != nil {
            var request = URLRequest(url: URL(string: "https://planet-zoo.herokuapp.com/api/planetzoo/animals")!)
            request.httpMethod = "GET"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let session = URLSession.shared
            let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
                let httpResponse = response as! HTTPURLResponse
                if httpResponse.statusCode == 200 {
                    let date = Date()
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "YY, MMM d, HH:mm:ss"
                    UserDefaults.standard.set("\(dateFormatter.string(from: date)) in terminated", forKey: "LASTTIMECALLED")
                    let content      = UNMutableNotificationContent()
                    content.title    = "API CALLED"
                    content.body = "http Status code\(httpResponse.statusCode)"
                    content.sound    = .default
                    let request = UNNotificationRequest(identifier: "1", content: content, trigger: nil)
                    UNUserNotificationCenter.current().add(request)
                }
            })
            task.resume()
        }
        
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("Locations: \(locations.last)")
        var request = URLRequest(url: URL(string: "https://planet-zoo.herokuapp.com/api/planetzoo/animals")!)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            let httpResponse = response as! HTTPURLResponse
            if httpResponse.statusCode == 200 {
                let date = Date()
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "YY, MMM d, HH:mm:ss"
                UserDefaults.standard.set(dateFormatter.string(from: date), forKey: "LASTTIMECALLED")
                let content      = UNMutableNotificationContent()
                content.title = "API CALLED"
                content.body = "http Status code\(httpResponse.statusCode)"
                content.sound    = .default
                let request = UNNotificationRequest(identifier: "1", content: content, trigger: nil)
                UNUserNotificationCenter.current().add(request)
            }
        })
        task.resume()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("ERRORRR")
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate
{
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void)
    {
        let id = response.notification.request.identifier
        print("Received notification with ID = \(id)")
        
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)
    {
        let id = notification.request.identifier
        print("Received notification with ID = \(id)")
        
        completionHandler([.sound])
    }
}
