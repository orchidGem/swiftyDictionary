//
//  Word+CoreDataClass.swift
//  HebrewDictionary
//
//  Created by Laura Evans on 1/7/18.
//  Copyright © 2018 Laura Evans. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Word)
public class Word: NSManagedObject {
/*
     convenience init(name: String, age: Int16, context: NSManagedObjectContext) {
     self.init(context: context)
     self.name = name
     self.age = age
     }
     
     func sayHello() {
     print("\(name) says hello!")
     }
 */
    
    convenience init(text: String, translation: String, context: NSManagedObjectContext) {
        self.init(context: context)
        self.text = text
        self.translation = translation
    }
    
    func describeWord() {
        print("text: \(self.text), translation: \(self.translation)")
    }
}
