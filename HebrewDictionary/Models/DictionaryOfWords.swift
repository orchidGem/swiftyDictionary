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
    
    func search(byWord word: Word) -> Word? {
        if let foundWord = self.words?.first(where: { (x) -> Bool in
            x.text == word.text
        }) {
            return foundWord
        }
        
        return nil
    }
    
    func search(byText text: String) -> [Word] {
        var words: [Word] = []
        let searchText = text.lowercased()
        
        if let foundWords = self.words?.filter({ (word) -> Bool in
            guard let text = word.text, let translation = word.translation else {
                return false
            }
            
            if text.contains(searchText) || translation.contains(searchText) {
                return true
            } else {
                return false
            }
        }) {
            words = foundWords
        }
        
        return words
        
    }
    
    func getIndexOfWord(byID: UUID) -> Int? {
        if let foundIndex = self.words?.index(where: { (word) -> Bool in
            word.itemIdentifier == byID
        }) {
            return foundIndex
        } else {
            return nil
        }
    }
    
    func addWord(word: Word) -> Bool {
        
        // check if word already exists, if not then add
        if let _ = self.search(byWord: word) {
            print("word already exists")
            return false
        } else {
            self.words?.append(word)
            word.saveItem()
            return true
        }
    }
    
    func editWord(id: UUID, text: String, translation: String, completionHandler: (Bool) -> Void) {
        if let index = self.words?.index(where: { (word) -> Bool in
            word.itemIdentifier == id
        }) {
            self.words![index].text = text
            self.words![index].translation = translation
            self.words![index].saveItem()
            completionHandler(true)
        } else {
            completionHandler(false)
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
