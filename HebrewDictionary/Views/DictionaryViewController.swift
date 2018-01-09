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

    @IBOutlet weak var tableview: UITableView!
    @IBOutlet var addWordView: UIView!
    @IBOutlet weak var addWordTextfield: UITextField!
    @IBOutlet weak var addTranslationTextfield: UITextField!
    
    var dictionary: DictionaryOfWords = DictionaryOfWords()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        tableview.dataSource = self
        tableview.delegate = self
        addWordTextfield.delegate = self
        
        fetchWords()
        addWordViewToView()
        
        // add long press to tableview
        let longPressTableCell = UILongPressGestureRecognizer(target: self, action: #selector(self.longPressWord))
        longPressTableCell.minimumPressDuration = 0.2
        tableview.addGestureRecognizer(longPressTableCell)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("did receive memory warning")
    }
    
    //MARK: - custom methods
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
    
    @objc func longPressWord(longPress: UILongPressGestureRecognizer) {
        
        if longPress.state != .began && longPress.state != .ended {
            return
        }
        
        // get touchpoint and index of cell
        let touchPoint = longPress.location(in: tableview)
        guard let indexPath = tableview.indexPathForRow(at: touchPoint) else {
            return
        }
        
        // get word
        guard let words = dictionary.words, words.count >= indexPath.row else { return }
        
        let word = words[indexPath.row]
        let cell = tableview.cellForRow(at: indexPath)
        
        // show text on began and text on end
        if longPress.state == .began {
            cell?.textLabel?.text = word.text
            
        } else {
            cell?.textLabel?.text = word.translation
        }
    }
    
    @IBAction func saveWordTapped(_ sender: Any) {
        // add word
    }
    
    @IBAction func cancelAddWordTapped(_ sender: Any) {
        moveAddWordView(direction: .down)
        view.endEditing(true)
    }
    
    func showAddWordAlert() {
        let alert = UIAlertController(title: "Add Word", message: nil, preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "text"
        }
        alert.addTextField { (textfield) in
            textfield.placeholder = "translation"
        }
        let addAction = UIAlertAction(title: "Add", style: .default) { (_) in
            guard let text = alert.textFields?.first?.text, let translation = alert.textFields?.last?.text else { return }
            self.addWord(text: text, translation: translation)
        }
        alert.addAction(addAction)
        present(alert, animated: true, completion: nil)
    }
    
    func addWord(text: String, translation: String) {
        let word = Word(text: text, translation: translation, context: PersistenceService.context)
        let wordAdded = self.dictionary.addWord(word: word)
        
        if wordAdded {
            PersistenceService.saveContext()
            self.tableview.reloadData()
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
        
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.selectionStyle = .none
        
        if let words = dictionary.words {
            cell.textLabel?.text = words[indexPath.item].translation
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let words = dictionary.words else { return }
        
        let word = words[indexPath.item]
        word.describeWord()
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
        moveAddWordView(direction: .up)
    }
    
    func moveAddWordView(direction: AddWordViewDirection) {
        
        var yPoint = view.frame.height - addWordView.frame.height // point for up
        
        if direction == .down {
            yPoint = getAddWordViewYPoint()
        }
        
        UIView.animate(withDuration: 0.3, animations: {
            self.addWordView.frame.origin = CGPoint(x: 0, y: yPoint)
        })
    }
}
