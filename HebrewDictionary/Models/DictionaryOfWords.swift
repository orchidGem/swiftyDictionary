//
//  WordDictionary.swift
//  HebrewDictionary
//
//  Created by Laura Evans on 1/8/18.
//  Copyright © 2018 Laura Evans. All rights reserved.
//

import Foundation

class DictionaryOfWords: NSObject {
    private(set) var words: [Word]?
    
    override init() {
        super.init()
    }
    
    func setWords(words: [Word]) {
        self.words = words
        self.shuffleWords()
    }
    
    func getAllWords() -> [Word]? {
        return self.words
    }
    
    func search(word: Word) -> Word? {        
        if let foundWord = self.words?.first(where: { (x) -> Bool in
            x.text == word.text
        }) {
            return foundWord
        }
        
        return nil
    }
    
    func addWord(word: Word) -> Bool {
        
        // check if word already exists, if not then add
        if let _ = self.search(word: word) {
            print("word already exists")
            return false
        } else {
            self.words?.append(word)
            word.saveItem()
            return true
        }
    }
    
    func deleteWord(byWord: Word) -> Bool {
        print("delete word")
        return true
    }
    
    func deleteWord(byIndex: Int) {
        self.words?[byIndex].deleteItem()
        self.words?.remove(at: byIndex)
    }
    
    func showTranslation(_ show: Bool, index: Int) {
        self.words![index].translationShown = show
    }
    
    func shuffleWords() {
        self.words?.shuffle()
    }
    
}
