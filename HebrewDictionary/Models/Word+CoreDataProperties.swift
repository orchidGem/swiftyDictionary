//
//  Word+CoreDataProperties.swift
//  HebrewDictionary
//
//  Created by Laura Evans on 1/7/18.
//  Copyright © 2018 Laura Evans. All rights reserved.
//
//

import Foundation
import CoreData


extension Word {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Word> {
        return NSFetchRequest<Word>(entityName: "Word")
    }

    @NSManaged public var text: String?
    @NSManaged public var translation: String?
    @NSManaged public var shownInNotification: Bool
}
