//
//  NotificationViewController.swift
//  WordNotificationViewController
//
//  Created by Laura Evans on 2/13/18.
//  Copyright © 2018 Laura Evans. All rights reserved.
//

import UIKit
import UserNotifications
import UserNotificationsUI

class NotificationViewController: UIViewController, UNNotificationContentExtension {
    
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
    
    func didReceive(_ notification: UNNotification) {
        
    }
    
    func didReceive(_ response: UNNotificationResponse, completionHandler completion: @escaping (UNNotificationContentExtensionResponseOption) -> Void) {
        
        if response.actionIdentifier == "viewTranslation" {
            self.viewTranslation()
        } else if response.actionIdentifier == "needsPractice" {
            self.textLabel.text = "needs practice!"
        } else {
            showAnotherWord()
        }
    }
    
    func showAnotherWord() {
        translationLabel.isHidden = true
        word = WordNotificationsManager.getRandomWord()
    }
    
    func viewTranslation() {
        translationLabel.isHidden = false
    }

}
