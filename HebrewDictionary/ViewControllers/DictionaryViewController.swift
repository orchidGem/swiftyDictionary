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
    var fadedView: UIView!
    var editedWord: Word?
    
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var tableviewBottomConstraint: NSLayoutConstraint!
    
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
    
    //MARK: - Set up methods
    
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
    
    func getAddWordViewYPoint() -> CGFloat {
        return view.frame.height + tableviewBottomConstraint.constant
    }
    
    
    func fetchWords() {
        let words = DataManager.loadAll(Word.self, identifier: Word.identifier)
        
        self.dictionary.setWords(words: words)
        self.tableview.reloadData()
    }

    func addWordViewToView() {
        view.addSubview(addWordView)
        let height = addWordView.frame.height
        let yPoint = getAddWordViewYPoint()
        addWordView.frame = CGRect(x: 0, y: yPoint, width: view.frame.width, height: height)
        
        // add faded background to view
        fadedView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        fadedView.backgroundColor = UIColor.darkGray
        fadedView.alpha = 0
        view.insertSubview(fadedView, belowSubview: addWordView)
        
    }
    
    //MARK: - outlet methods
    
    @IBAction func saveWordTapped(_ sender: Any) {
        
        if let text = addWordTextfield.text, text.isEmpty, let translation = addTranslationTextfield.text, translation.isEmpty {
            return
        }
        
        if let editedWord = editedWord {
            editedWord.saveItem()
            self.editedWord = nil
        } else {
            addWord(text: addWordTextfield.text, translation: addTranslationTextfield.text)
        }
    }
    
    @IBAction func cancelAddWordTapped(_ sender: Any) {
        view.endEditing(true)
    }
    
    func addWord(text: String?, translation: String?) {
        
        let word = Word(text: text, translation: translation, translationShown: false, shownInNotification: false, createdDate: Date(), itemIdentifier: UUID())
        
        let wordAdded = self.dictionary.addWord(word: word)
        
        if wordAdded {
            self.tableview.reloadData()
            let indexPath = IndexPath(row: (dictionary.words?.count ?? 0) - 1, section: 0)
            self.tableview.scrollToRow(at: indexPath, at: .top, animated: true)
            self.moveAddWordView(direction: .down)
            
            // clear textfield
            self.addWordTextfield.text = nil
            self.addTranslationTextfield.text = nil
            self.view.endEditing(true)
            
        } else {
            // TODO: show alert that word already exists
        }
        
    }
    
    @IBAction func shuffle(_ sender: Any) {
        if dictionary.words == nil {
            return
        }
        dictionary.shuffleWords()
        tableview.reloadData()
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
            setTextAndColor(word: word, cell: cell)
        }
        
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard
            var words = dictionary.words,
            let cell = tableView.cellForRow(at: indexPath) as? WordTableViewCell else {
                return
        }
        
        var word = words[indexPath.item]
        word.translationShown = !word.translationShown
        dictionary.showTranslation( word.translationShown, index: indexPath.row)
        
        setTextAndColor(word: word, cell: cell)
        
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completionHandler) in
            self.deleteWord(indexPath: indexPath)
            completionHandler(true)
        }
        
        let editAction = UIContextualAction(style: .normal, title: "Edit") { (action, view, completionHandler) in
            self.showEditWord(indexPath: indexPath)
            completionHandler(true)
        }
        
        deleteAction.backgroundColor = UIColor(named: "red")
        deleteAction.image = UIImage(named: "delete")
        editAction.backgroundColor = UIColor(named: "lightGreen")
        editAction.image = UIImage(named: "edit")
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction, editAction])
        return configuration
    }
    
    func deleteWord(indexPath: IndexPath) {
        dictionary.deleteWord(byIndex: indexPath.row)
    }
    
    func showEditWord(indexPath: IndexPath) {
        guard let word = dictionary.words?[indexPath.row] else {
            return
        }
        
        editedWord = word
        
        addWordTextfield.becomeFirstResponder()
        addWordTextfield.text = word.text
        addTranslationTextfield.text = word.translation
    }
    
    func setTextAndColor(word: Word, cell: WordTableViewCell) {
        cell.wordLabel.text = word.translationShown ? word.text : word.translation
        cell.wordLabel.textColor = word.translationShown ? UIColor.white : UIColor(named:"darkGray")
        cell.backgroundColor = word.translationShown ? UIColor(named: "darkGreen") : UIColor.clear
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
        
        let show = direction == .down ? false : true
        
        animateFadedBackground(show: show)
        
        UIView.animate(withDuration: 0.3, animations: {
            self.addWordView.frame.origin = CGPoint(x: 0, y: yPoint)
        })
    }
    
    func animateFadedBackground(show: Bool) {
        
        var alpha: CGFloat = 0 // default for hidden
        
        if show {
            alpha = 0.5
        }
        
        UIView.animate(withDuration: 0.3, animations: {
            self.fadedView.alpha = alpha
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
