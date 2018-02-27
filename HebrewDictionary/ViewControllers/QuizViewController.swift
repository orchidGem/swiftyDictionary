//
//  QuizViewController.swift
//  HebrewDictionary
//
//  Created by Laura Evans on 2/27/18.
//  Copyright © 2018 Laura Evans. All rights reserved.
//

import UIKit

class QuizViewController: UIViewController {
    
    var word: Word? {
        didSet {
            textLabel.text = word?.text
            translationLabel.text = word?.translation
        }
    }
    
    @IBOutlet weak var textLabel : UILabel!
    @IBOutlet weak var translationLabel : UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let size = view.bounds.size
        preferredContentSize = CGSize(width: size.width, height: size.height / 2)
        
        translationLabel.isHidden = true
        word = WordNotificationsManager.getRandomWord()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        WordNotificationsManager.schedule(type: .Hourly)
    }
    
    /*
    func didReceive(_ response: UNNotificationResponse, completionHandler completion: @escaping (UNNotificationContentExtensionResponseOption) -> Void) {
        
        if response.actionIdentifier == "viewTranslation" {
            self.viewTranslation()
        } else if response.actionIdentifier == "needsPractice" {
            self.textLabel.text = "needs practice!"
        } else {
            showAnotherWord()
        }
    }
 */
    
    @IBAction func showTranslation(_ sender: Any) {
        viewTranslation()
    }
    
    @IBAction func needsPractice(_ sender: Any) {
        print("needs practice")
    }
    
    @IBAction func showAnotherWord(_ sender: Any) {
        showAnotherWord()
    }
    
    @IBAction func close(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func showAnotherWord() {
        translationLabel.isHidden = true
        word = WordNotificationsManager.getRandomWord()
    }
    
    func viewTranslation() {
        translationLabel.isHidden = false
    }
    
}
