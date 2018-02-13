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
    
    @IBOutlet weak var textLabel : UILabel!
    @IBOutlet weak var translationLabel : UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let size = view.bounds.size
        preferredContentSize = CGSize(width: size.width, height: size.height / 2)
        
        translationLabel.isHidden = true
    }
    
    func didReceive(_ notification: UNNotification) {
        
        self.textLabel.text = notification.request.content.body
        
        if let userInfo = notification.request.content.userInfo as? [String: String], let translation = userInfo["translation"] {
            self.translationLabel.text = translation
        }
    }
    
    func didReceive(_ response: UNNotificationResponse, completionHandler completion: @escaping (UNNotificationContentExtensionResponseOption) -> Void) {
        
        if response.actionIdentifier == "viewTranslation" {
            self.viewTranslation()
        } else {
            self.textLabel.text = "needs practice!"
        }
    }
    
    func viewTranslation() {
        translationLabel.isHidden = false
    }

}
