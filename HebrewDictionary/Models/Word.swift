//
//  Word.swift
//  Word
//
//  Created by Laura Evans on 1/21/18.
//  Copyright © 2018 Laura Evans. All rights reserved.
//

import Foundation

struct Word: Codable {
    var text: String?
    var translation: String?
    var translationShown: Bool = false
    var shownInNotification: Bool
    var createdDate: Date
    var itemIdentifier: UUID
    
    static let identifier: String = "group.WordNotifications"
    
    func saveItem() {
        DataManager.save(self, with: itemIdentifier.uuidString, identifier: Word.identifier)
    }
    
    func deleteItem() {
        DataManager.delete(itemIdentifier.uuidString, identifier: Word.identifier)
    }
    
    mutating func markAsShownInNotification() {
        self.shownInNotification = true
    }
    
    mutating func markAsNotShownInNotification() {
        self.shownInNotification = false
    }
    
}

