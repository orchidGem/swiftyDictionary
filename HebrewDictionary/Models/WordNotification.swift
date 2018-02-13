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
        
        guard let text = self.word.text, let translation = self.word.translation else { return }

        let content = UNMutableNotificationContent()
        content.title = "Quick Word Test!"
        content.body = text
        content.sound = UNNotificationSound.default()
        content.categoryIdentifier = "wordCategory"
        content.userInfo = ["translation": translation]

//        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: self.date)
//        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate,repeats: false)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)

        let request = UNNotificationRequest(identifier: "wordNotification", content: content, trigger: trigger)
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
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
    
    static func setUpCategories() {
        // Define actions
        let viewTranslation = UNNotificationAction(identifier: "viewTranslation", title: "View translation", options: [])
        let needsPractice = UNNotificationAction(identifier: "needsPractice", title: "Needs practice", options: [])
        
        // Add actions to a wordCategory
        let category = UNNotificationCategory(identifier: "wordCategory", actions: [viewTranslation, needsPractice], intentIdentifiers: [], options: [])
        UNUserNotificationCenter.current().setNotificationCategories([category])
    }
    
    static func schedule() {
        print("scheduling word notification")
        let _ = WordNotification()
    }
    
    private static func chooseRandomWord() -> Word {
        
        let fetchRequest: NSFetchRequest<Word> = Word.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "shownInNotification == false")
        
        do {
            let words = try PersistenceService.context.fetch(fetchRequest)
            
            if words.count == 0 {
                return Word(text: "Test", translation: "Mivchan", context: PersistenceService.context)
            }
            
            let randomNum = Int(arc4random_uniform(UInt32(words.count - 1)))
            return words[randomNum]
        } catch {
            print("error")
        }
        
        return Word(text: "Test", translation: "Mivchan", context: PersistenceService.context)
    }
    
}
