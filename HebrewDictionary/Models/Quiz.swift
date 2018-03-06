//
//  Quiz.swift
//  HebrewDictionary
//
//  Created by Laura Evans on 3/6/18.
//  Copyright © 2018 Laura Evans. All rights reserved.
//

import Foundation

struct Quiz {
    var dict: DictionaryOfWords!
    var lowWeightedWords: [Word] = []
    var highWeightedWords: [Word] = []
    var word: Word?

    init(dict: DictionaryOfWords!) {
        self.dict = dict
        self.sortWordsByWeight()
    }

    mutating func sortWordsByWeight() {
        print("sort words by weight now")

        guard let words = self.dict.words else { return }
        // loop through dictionary to sort words by weight
        for word in words {
            if word.weightType == .High {
                self.highWeightedWords.append(word)
            } else {
                self.lowWeightedWords.append(word)
            }
        }
    }

    mutating func pickRandomWord() -> Word? {
        // initialize a weight array
        guard let weight = self.chooseWeight() else {
            print("quiz is over")
            return nil
        }

        var word: Word!

        // pick random number from chosen weight words array count
        if weight == .High {
            let randomNumber = Int(arc4random_uniform(UInt32(highWeightedWords.count)))
            word = highWeightedWords.remove(at: randomNumber)
        } else {
            let randomNumber = Int(arc4random_uniform(UInt32(lowWeightedWords.count)))
            word = lowWeightedWords.remove(at: randomNumber)
        }

        print("selected word:", word.text)
        return word
    }

    private func chooseWeight() -> WeightType? {

        var weight: WeightType!
        // if words in low array andn ot in high, make weight low
        if self.lowWeightedWords.isEmpty == false && self.highWeightedWords.isEmpty {
            weight = .Low
        } else if self.lowWeightedWords.isEmpty && self.highWeightedWords.isEmpty == false {
            weight = .High
        } else if self.lowWeightedWords.isEmpty && self.lowWeightedWords.isEmpty {
            return nil
        } else {
            let randomNum = drand48()

            // select weight from random number
            if randomNum <= WeightType.Low.rawValue {
                weight = .Low
            } else {
                weight = .High
            }
        }

        return weight
    }

    func showTranslation() {
        // show translation of word
    }
}

