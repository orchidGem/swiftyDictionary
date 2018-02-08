//
//  WordNotification.swift
//  HebrewDictionary
//
//  Created by Laura Evans on 2/8/18.
//  Copyright © 2018 Laura Evans. All rights reserved.
//

import Foundation
import UserNotifications

class WordNotification: NSObject {
    
    var word: Word
    var date: Date
    
    override init() {
        self.word = WordNotification.chooseRandomWord()
        
        // calculate date for word
        self.date = Calendar.current.date(byAdding: .minute, value: 1, to: Date())!
        
        super.init()
        self.schedule()
    }
    
    private func schedule(){
        
        guard let text = self.word.text else { return }

        let content = UNMutableNotificationContent()
        content.title = text
        content.sound = UNNotificationSound.default()

        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: self.date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate,repeats: false)

        let request = UNNotificationRequest(identifier: "UYLLocalNotification", content: content, trigger: trigger)
        let center = UNUserNotificationCenter.current()
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
            }
        }
    }
    
    static func schedule() {
        print("scheduling word notification")
        let _ = WordNotification()
    }
    
    private static func chooseRandomWord() -> Word {
        return Word(text: "Test", translation: "Mivchan", context: PersistenceService.context)
    }
    
}
