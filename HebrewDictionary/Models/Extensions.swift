//
//  Extensions.swift
//  HebrewDictionary
//
//  Created by Laura Evans on 1/7/18.
//  Copyright © 2018 Laura Evans. All rights reserved.
//

import UIKit
import Foundation

extension Array {
    mutating func shuffle() {
        var count = self.count
        
        while(count > 0) {
            let randomIndex = Int(arc4random_uniform(UInt32(count)))
            count -= 1
            swapAt(randomIndex, count)
        }
    }
}

