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
            textLabel.text = word?.translation
            translationLabel.text = word?.text
        }
    }
    var initialTouchPoint: CGPoint = CGPoint(x: 0,y: 0)
    
    @IBOutlet weak var textLabel : UILabel!
    @IBOutlet weak var translationLabel : UILabel!
    
    //MARK: - lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*
        let size = view.bounds.size
        preferredContentSize = CGSize(width: size.width, height: size.height / 2)
        */
        
        translationLabel.isHidden = true
        word = WordNotificationsManager.getRandomWord()
        
        setupPanGesture()
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
   
    //MARK: - outlet action methods
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
    
    //MARK - custom methods
    func showAnotherWord() {
        translationLabel.isHidden = true
        word = WordNotificationsManager.getRandomWord()
    }
    
    func viewTranslation() {
        translationLabel.isHidden = false
    }
}

//MARK: - pan gesture extension
extension QuizViewController {
    
    func setupPanGesture() {
        let gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(swipeDown(gestureRecognizer:)))
        view.addGestureRecognizer(gestureRecognizer)
    }
    
    @objc func swipeDown(gestureRecognizer: UIPanGestureRecognizer) {
        
        print("swiping down")
        
        let touchPoint = gestureRecognizer.location(in: self.view?.window)
        print("touchpoint", touchPoint)
        
        if gestureRecognizer.state == UIGestureRecognizerState.began {
            print("began")
            initialTouchPoint = touchPoint
        } else if gestureRecognizer.state == UIGestureRecognizerState.changed {
            if touchPoint.y - initialTouchPoint.y > 0 {
                print("changed")
                self.view.frame = CGRect(x: 0, y: touchPoint.y - initialTouchPoint.y, width: self.view.frame.size.width, height: self.view.frame.size.height)
            }
        } else if gestureRecognizer.state == UIGestureRecognizerState.ended || gestureRecognizer.state == UIGestureRecognizerState.cancelled {
            print("cancelled or ended")
            if touchPoint.y - initialTouchPoint.y > 100 {
                self.dismiss(animated: true, completion: nil)
            } else {
                UIView.animate(withDuration: 0.3, animations: {
                    self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
                })
            }
        }
    }
}
