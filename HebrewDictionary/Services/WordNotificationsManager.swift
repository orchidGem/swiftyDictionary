//
//  WordNotification.swift
//  HebrewDictionary
//
//  Created by Laura Evans on 2/8/18.
//  Copyright © 2018 Laura Evans. All rights reserved.
//

import Foundation
import UserNotifications
import CoreData

class WordNotificationsManager {
    
    init() {}
    
    static let notificationCategory: String = "wordCategory"
    
    static func scheduleNotifications() {
        
        let center = UNUserNotificationCenter.current()
        center.getPendingNotificationRequests { (notificationRequests) in
            
            var scheduleMorning: Bool = true
            var scheduleHourly: Bool = true
            
            // check notifications type
            for request in notificationRequests {
                if request.identifier == WordNotificationType.Morning.rawValue {
                    scheduleMorning = false
                    continue
                } else if request.identifier == WordNotificationType.Hourly.rawValue {
                    scheduleHourly = false
                    continue
                }
            }
            
            // schedule notifications if dont already exist
            if scheduleHourly {
                WordNotificationsManager.schedule(type: .Hourly)
            }
            
            if scheduleMorning {
                WordNotificationsManager.schedule(type: .Morning)
            }
        }
    }
    
    static func schedule(type: WordNotificationType, removePending: Bool = false){
        
        let content = UNMutableNotificationContent()
        content.title = "Quick Hebrew Test!"
        content.sound = UNNotificationSound.default()
        content.categoryIdentifier = self.notificationCategory
        
        var trigger: UNNotificationTrigger!
        var identifier: String!
        
        if type == .Hourly {
            
            // don't schedule if past ten
            let hour = Calendar.current.component(.hour, from: Date())
            if hour < 20 {
                trigger = UNTimeIntervalNotificationTrigger(timeInterval: 60*60*2, repeats: false)
                identifier = WordNotificationType.Hourly.rawValue
            }
        } else {
            trigger = UNCalendarNotificationTrigger(dateMatching: DateComponents(hour: 9), repeats: true)
            
            identifier = WordNotificationType.Morning.rawValue
        }
        
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        let center = UNUserNotificationCenter.current()
        
        if removePending {
            center.removeAllPendingNotificationRequests()
        }
        
        center.add(request, withCompletionHandler: { (error) in
            if let error = error {
                print("error", error)
            } else {
                print("notification scheduled")
            }
        })
    }
    
    static func requestionNotificationAuthorization() {
        let center = UNUserNotificationCenter.current()
        let options: UNAuthorizationOptions = [.alert, .sound]
        
        center.requestAuthorization(options: options) {
            (granted, error) in
            if granted {
                print("permission granted")
                self.setUpCategories()
                self.scheduleNotifications()
            }
        }
    }
    
    static func setUpCategories() {
        // Define actions
        let viewTranslation = UNNotificationAction(identifier: "viewTranslation", title: "View translation", options: [])
        let needsPractice = UNNotificationAction(identifier: "needsPractice", title: "Needs practice", options: [])
        let showAnotherWord = UNNotificationAction(identifier: "showAnotherWord", title: "Show Another Word", options: [])
        
        // Add actions to a wordCategory
        let category = UNNotificationCategory(identifier: self.notificationCategory, actions: [viewTranslation, needsPractice, showAnotherWord], intentIdentifiers: [], options: [])
        UNUserNotificationCenter.current().setNotificationCategories([category])
    }
    
    static func getRandomWord() -> Word {
        
        let words = DataManager.loadAll(Word.self, identifier: Word.identifier).sorted(by: {
            $0.createdDate < $1.createdDate
        })
        
        if words.count < 0 {
            return Word(text: "text", translation: "translation", translationShown: false, shownInNotification: false, createdDate: Date(), itemIdentifier: UUID())
        }
        
        let randomNumber = Int(arc4random_uniform(UInt32(words.count)))
        
        return words[randomNumber]
    }
    
}
