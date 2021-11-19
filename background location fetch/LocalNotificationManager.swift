//
//  LocalNotificationManager.swift
//  background location fetch
//
//  Created by VinBrain on 19/11/2021.
//

import Foundation
import UserNotifications

struct Notification {
    var id:String
    var title:String
    var datetime:DateComponents
}

class LocalNotificationManager
{
    var notifications = [Notification]()
 
    func listScheduledNotifications()
    {
        UNUserNotificationCenter.current().getPendingNotificationRequests { notifications in
            
            for notification in notifications {
                print(notification)
            }
        }
    }
    
    private func requestAuthorization()
    {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
        }
    }
    
    func schedule()
    {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            
            switch settings.authorizationStatus {
            case .notDetermined:
                self.requestAuthorization()
            default:
                break // Do nothing
            }
        }
    }
}
