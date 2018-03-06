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
    var shownInNotification: Bool = false
    var createdDate: Date
    var itemIdentifier: UUID
    var archived: Bool?
    var weightType: WeightType?
    
    static let identifier: String = "group.WordNotifications"
    
    init(text: String?, translation: String?) {
        self.text = text
        self.translation = translation
        self.createdDate = Date()
        self.itemIdentifier = UUID()
        self.archived = false
        self.weightType = WeightType.High
    }
    
    func saveItem() {
        _ = DataManager.save(self, with: itemIdentifier.uuidString, identifier: Word.identifier)
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
    
    mutating func archive() {
        self.archived = true
        self.saveItem()
    }
    
    mutating func unarchive() {
        self.archived = false
        self.saveItem()
    }
    
    mutating func changeWeightToHigh() {
        self.weightType = .High
        self.saveItem()
    }
    
    mutating func changeWeightToLow() {
        self.weightType = .Low
        self.saveItem()
    }
    
    mutating func toggleWeight() {
        if self.weightType == .Low {
            self.weightType = .High
        } else {
            self.weightType = .Low
        }
        self.saveItem()
    }
    
}

