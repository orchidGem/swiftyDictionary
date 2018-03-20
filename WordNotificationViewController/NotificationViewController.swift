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

class NotificationViewController: QuizViewController, UNNotificationContentExtension {
    
    var answer: String?
    
    //MARK: - Lifecycle methods
    override func loadView() {
        Bundle.main.loadNibNamed("QuizViewController", owner: self, options: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // hide buttons
        self.closeButton.isHidden = true
        self.viewTranslationButton.isHidden = true
        self.showAnotherButton.isHidden = true
        
        textLabel.font = textLabel.font.withSize(35)
        translationLabel.font = textLabel.font.withSize(30)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let size = view.bounds.size
        preferredContentSize = CGSize(width: size.width, height: size.height / 2)
        
        verticalConstraint.constant = 0
        self.view.layoutIfNeeded()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        WordNotificationsManager.schedule(type: .Hourly)
    }
    
    //MARK: - notification methods
    
    func didReceive(_ notification: UNNotification) {
        print("did receive")
    }
    
    func didReceive(_ response: UNNotificationResponse, completionHandler completion: @escaping (UNNotificationContentExtensionResponseOption) -> Void) {
        
        if response.actionIdentifier != "enterTranslation" {
            completion(.dismiss)
        }
        
        guard let textResponse = response as? UNTextInputNotificationResponse else {
            completion(.dismiss)
            return
        }
        
        let text = textResponse.userText
        
        if self.answer == nil {
            self.answer = text
        } else {
            completion(.doNotDismiss)
            return
        }
        
        self.submitAnswer()
        
        completion(.doNotDismiss)
    }
    
}
