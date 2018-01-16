//
//  ViewController.swift
//  HebrewDictionary
//
//  Created by Laura Evans on 1/7/18.
//  Copyright © 2018 Laura Evans. All rights reserved.
//

import UIKit
import CoreData

class DictionaryViewController: UIViewController {

    var dictionary: DictionaryOfWords = DictionaryOfWords()
    var keyboardHeight: CGFloat = 0
    
    @IBOutlet weak var tableview: UITableView!
    
    // MARK: - Add word view properties
    @IBOutlet var addWordView: UIView!
    @IBOutlet weak var addWordTextfield: CustomTextField!
    @IBOutlet weak var addTranslationTextfield: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        addWordTextfield.delegate = self
        addWordTextfield.language = "he"
        
        setUpTableview()
        fetchWords()
        addWordViewToView()
        setupKeyboardNotifications()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("did receive memory warning")
    }
    
    //MARK: - custom methods
    
    func setUpTableview() {
        tableview.dataSource = self
        tableview.delegate = self
        tableview.rowHeight = UITableViewAutomaticDimension
        tableview.estimatedRowHeight = 200
    }
    
    func setupKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow,object: nil
        )
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide,object: nil
        )
    }
    
    func addWordViewToView() {
        view.addSubview(addWordView)
        let height = addWordView.frame.height
        let yPoint = getAddWordViewYPoint()
        addWordView.frame = CGRect(x: 0, y: yPoint, width: view.frame.width, height: height)
    }
    
    func getAddWordViewYPoint() -> CGFloat {
        return view.frame.height - 80
    }
    
    
    func fetchWords() {
        let fetchRequest: NSFetchRequest<Word> = Word.fetchRequest()
        
        do {
            let words = try PersistenceService.context.fetch(fetchRequest)
            self.dictionary.setWords(words: words)
            self.tableview.reloadData()
        } catch {
            print("error")
        }
    }
    
    @IBAction func saveWordTapped(_ sender: Any) {
        // add word
        
        if let text = addWordTextfield.text, text.isEmpty, let translation = addTranslationTextfield.text, translation.isEmpty {
            return
        }
        
        addWord(text: addWordTextfield.text, translation: addTranslationTextfield.text)
    }
    
    @IBAction func cancelAddWordTapped(_ sender: Any) {
        //moveAddWordView(direction: .down)
        view.endEditing(true)
    }
    
    func addWord(text: String?, translation: String?) {
        let word = Word(text: text, translation: translation, context: PersistenceService.context)
        let wordAdded = self.dictionary.addWord(word: word)
        
        if wordAdded {
            PersistenceService.saveContext()
            self.tableview.reloadData()
            self.moveAddWordView(direction: .down)
            
            // clear textfield
            self.addWordTextfield.text = nil
            self.addTranslationTextfield.text = nil
            self.view.endEditing(true)
            
        } else {
            // TODO: show alert that word already exists
        }
        
    }
}

extension DictionaryViewController: UITableViewDelegate, UITableViewDataSource {
    
    //MARK: - tabelview datasource / delegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dictionary.words?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! WordTableViewCell
        
        if let words = dictionary.words {
            let word = words[indexPath.item]
            cell.wordLabel.text = word.translationShown ? word.text : word.translation
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard
            let words = dictionary.words,
            let cell = tableView.cellForRow(at: indexPath) as? WordTableViewCell else {
                return
        }
        
        let word = words[indexPath.item]
        word.translationShown = !word.translationShown
        
        cell.wordLabel.text = word.translationShown ? word.text : word.translation
        
        tableView.beginUpdates()
        tableView.endUpdates()
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            dictionary.deleteWord(byIndex: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}

extension DictionaryViewController: UITextFieldDelegate {
    
    //MARK: - AddWordView methods and textfield delegate and custom methods
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print("did begin editing")
        //moveAddWordView(direction: .up)
    }
    
    func moveAddWordView(direction: AddWordViewDirection) {
        
        var yPoint = view.frame.height - (keyboardHeight + addWordView.frame.height)
        
        if direction == .down {
            yPoint = getAddWordViewYPoint()
        }
        
        UIView.animate(withDuration: 0.3, animations: {
            self.addWordView.frame.origin = CGPoint(x: 0, y: yPoint)
        })
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        print("keyboard will show")
        if let keyboardFrame: NSValue = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            keyboardHeight = keyboardRectangle.height
            moveAddWordView(direction: .up)
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        moveAddWordView(direction: .down)
    }
}
