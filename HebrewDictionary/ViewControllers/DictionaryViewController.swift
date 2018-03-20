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
    let search = UISearchController(searchResultsController: nil)
    var searchResults: [Word]?
    var showAddWordView: Bool = false
    
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var tableviewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollUpButton : UIButton!
    
    // MARK: - Add word view properties
    @IBOutlet var addWordView: UIView!
    @IBOutlet weak var addWordTextfield: CustomTextField!
    @IBOutlet weak var addTranslationTextfield: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTextFields()
        setupBalloonButton()
        setUpTableview()
        setupSearchBar()
        fetchWords()
        addWordViewToView()
        setupKeyboardNotifications()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if WordNotificationsManager.didOpenFromNotification {
            showQuizView()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(showQuizView), name: NSNotification.Name(rawValue: "didReceiveNotification"), object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("did receive memory warning")
    }
    
    //MARK: - Set up methods
    func setupTextFields() {
        addWordTextfield.delegate = self
        addWordTextfield.language = "he"
    }
    
    func setupBalloonButton() {
        scrollUpButton.isHidden = true
        scrollUpButton.alpha = 0
        scrollUpButton.layer.cornerRadius = scrollUpButton.frame.height / 2
        scrollUpButton.clipsToBounds = true

    }
    
    func setUpTableview() {
        tableview.dataSource = self
        tableview.delegate = self
        tableview.rowHeight = UITableViewAutomaticDimension
        tableview.estimatedRowHeight = 200
    }
    
    func setupSearchBar() {
        search.searchResultsUpdater = self
        search.searchBar.delegate = self
        navigationItem.hidesSearchBarWhenScrolling = false
        search.dimsBackgroundDuringPresentation = false
        self.navigationItem.searchController = search
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
        self.dictionary.setWords()
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
        
        guard let text = addWordTextfield.text, !text.isEmpty, let translation = addTranslationTextfield.text, !translation.isEmpty else {
            return
        }
        
        if let editedWord = self.editedWord {
            dictionary.editWord(id: editedWord.itemIdentifier, text: text, translation: translation, completionHandler: clearAddWordView)
            
            // updated search results
            if searchResults != nil {
                if let searchWordIndex = searchResults?.index(where: { (word) -> Bool in
                    word.itemIdentifier == editedWord.itemIdentifier
                }) {
                    searchResults![searchWordIndex].text = text
                    searchResults![searchWordIndex].translation = translation
                }
            }
            
        } else {
            addWord(text: addWordTextfield.text, translation: addTranslationTextfield.text, completionHandler: clearAddWordView)
        }
    }
    
    @IBAction func cancelAddWordTapped(_ sender: Any) {
        addWordTextfield.text = nil
        addTranslationTextfield.text = nil
        view.endEditing(true)
    }

    @IBAction func shuffle(_ sender: Any) {
        if dictionary.words == nil {
            return
        }
        dictionary.shuffleWords()
        tableview.reloadData()
    }
    
    @IBAction func takeQuizTapped(_ sender: Any) {
        self.showQuizView()
    }
    
    @IBAction func scrollUp(_ sender: Any) {
        let indexPath: IndexPath = IndexPath(row: 0, section: 0)
        tableview.scrollToRow(at: indexPath, at: .top, animated: true)
    }
    
    //MARK: - custom methods
    @objc func showQuizView() {
        
        WordNotificationsManager.didOpenFromNotification = false
        
        let quizViewController = QuizViewController(nibName: "QuizViewController", bundle: nil)
        quizViewController.modalPresentationStyle = .overFullScreen
        present(quizViewController, animated: true, completion: nil)
    }
    
    // clear out textfields and reload tableview after adding a word
    func clearAddWordView(_ success: Bool) {
        if success {
            
            var scrollToTop: Bool = true
            
            // if editing a word, don't scroll to top and clear out edited word
            if self.editedWord != nil {
                scrollToTop = false
                self.editedWord = nil
            }
            
            self.tableview.reloadData()
            
            // scroll to first row
            if scrollToTop {
                let indexPath = IndexPath(row: 0, section: 0)
                self.tableview.scrollToRow(at: indexPath, at: .top, animated: true)
            }
            
            self.moveAddWordView(direction: .down)
            
            // clear textfield
            self.addWordTextfield.text = nil
            self.addTranslationTextfield.text = nil
            self.view.endEditing(true)
        } else {
            print("didn't add word :(")
        }
    }
    
    func addWord(text: String?, translation: String?, completionHandler: (Bool) -> Void) {
        
        let word = Word(text: text, translation: translation)
        
        let wordAdded = self.dictionary.addWord(word: word)
        
        if wordAdded {
            completionHandler(true)
            
        } else {
            completionHandler(false)
        }
        
    }
    
    func toggleVisibilityOfScrollUpButton(indexPath: IndexPath) {
        // set max index Path with 40 as avg height of cell
        let maxIndex = Int(ceil(view.frame.height / 40) * 1.5 )
        
        if indexPath.row >= maxIndex {
            if scrollUpButton.isHidden {
                scrollUpButton.isHidden = false
                UIView.animate(withDuration: 0.3, animations: {
                    self.scrollUpButton.alpha = 1
                })
            }
        } else {
            if scrollUpButton.isHidden == false {
                UIView.animate(withDuration: 0.3, animations: {
                    self.scrollUpButton.alpha = 0
                }, completion: { (_) in
                    self.scrollUpButton.isHidden = true
                })
            }
        }
    }
}

extension DictionaryViewController: UITableViewDelegate, UITableViewDataSource {
    
    //MARK: - tabelview datasource / delegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let searchResults = searchResults {
            return searchResults.count
        } else {
            return dictionary.words?.count ?? 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        toggleVisibilityOfScrollUpButton(indexPath: indexPath)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! WordTableViewCell
        
        var word: Word?
        
        if let searchResults = searchResults {
            word = searchResults[indexPath.item]
        } else if let words = dictionary.words {
            word = words[indexPath.item]
        }
        
        if word !=  nil {
            setTextAndColor(word: word!, cell: cell)
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
        
        var word: Word!
        
        if let searchResults = searchResults {
            word = searchResults[indexPath.item]
        } else {
            word = words[indexPath.item]
        }

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
        
        let archiveAction = UIContextualAction(style: .destructive, title: "Archive") { (action, view, completionHandler) in
            self.archiveWord(indexPath: indexPath)
            completionHandler(true)
        }
        
        let weightAction = UIContextualAction(style: .normal, title: self.setTextOfWeightButton(indexPath: indexPath)) { (action, view, completionHandler) in
            self.changeWeightOfWord(indexPath: indexPath)
            completionHandler(true)
        }
        
        deleteAction.backgroundColor = UIColor(named: "red")
        deleteAction.image = UIImage(named: "delete")
        editAction.backgroundColor = UIColor(named: "lightGreen")
        editAction.image = UIImage(named: "edit")
        archiveAction.image = UIImage(named: "archive")
        archiveAction.backgroundColor = UIColor(named: "darkOrange")
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction, editAction, archiveAction, weightAction])
        return configuration
    }
    
    func deleteWord(indexPath: IndexPath) {
        
        var index: Int = indexPath.row
        
        if let searchResults = searchResults {
            let searchedWord = searchResults[indexPath.row]
            if let foundIndex = dictionary.getIndexOfWord(byID: searchedWord.itemIdentifier) {
                index = foundIndex
            }
        }
        
        dictionary.deleteWord(byIndex: index)
    }
    
    func changeWeightOfWord(indexPath: IndexPath) {
        if searchResults != nil {
            searchResults![indexPath.item].toggleWeight()
        } else if dictionary.words != nil {
            dictionary.toggleWordWeight(byIndex: indexPath.item)
        }
    }
    
    func archiveWord(indexPath: IndexPath) {
        var index: Int = indexPath.row
        
        if let searchResults = searchResults {
            let searchedWord = searchResults[indexPath.row]
            if let foundIndex = dictionary.getIndexOfWord(byID: searchedWord.itemIdentifier) {
                index = foundIndex
            }
        }
        
        dictionary.archiveWord(byIndex: index)
    }
    
    func setTextOfWeightButton(indexPath: IndexPath) -> String {
        var word: Word?
        if let searchResults = searchResults {
            word = searchResults[indexPath.item]
        } else if let words = dictionary.words {
            word = words[indexPath.item]
        }
        
        return word?.weightType == .Low ? "Mark High" : "Mark Low"
    }
    
    func showEditWord(indexPath: IndexPath) {
        
        var wordAtIndexPath: Word?
        
        if let searchResults = searchResults {
            wordAtIndexPath = searchResults[indexPath.row]
        } else {
            wordAtIndexPath = dictionary.words?[indexPath.row]
        }
        
        guard let word = wordAtIndexPath else {
            return
        }
        
        editedWord = word
        
        showAddWordView = true
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

//MARK: - AddWordView methods and textfield delegate and custom methods
extension DictionaryViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print("did begin editing")
        if textField == addWordTextfield {
            showAddWordView = true
            
            if editedWord == nil && searchResults != nil {
                search.dismiss(animated: true, completion: nil)
                search.searchBar.text = nil
                searchResults = nil
                tableview.reloadData()
            }
            
        }
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
        
        if showAddWordView == false {
            return
        }
        
        if let keyboardFrame: NSValue = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            keyboardHeight = keyboardRectangle.height
            moveAddWordView(direction: .up)
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        
        if showAddWordView {
            showAddWordView = false
        }
        
        moveAddWordView(direction: .down)
        
        if self.editedWord != nil {
            self.editedWord = nil
        }
    }
}

//MARK: - Search bar delegate methods
extension DictionaryViewController: UISearchResultsUpdating, UISearchBarDelegate {
    
    func updateSearchResults(for searchController: UISearchController) {
        print("searching")
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text else { return }
        searchResults = dictionary.search(byText: text)
        self.tableview.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchResults = nil
        tableview.reloadData()
    }
    
}

