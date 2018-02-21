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
        
    }
    
    static func requestionNotificationAuthorization() {
        let center = UNUserNotificationCenter.current()
        let options: UNAuthorizationOptions = [.alert, .sound]
        
        center.requestAuthorization(options: options) {
            (granted, error) in
            if granted {
                print("permission granted")
                self.setUpCategories()
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
