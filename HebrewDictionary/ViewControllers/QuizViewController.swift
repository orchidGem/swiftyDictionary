//
//  QuizViewController.swift
//  HebrewDictionary
//
//  Created by Laura Evans on 2/27/18.
//  Copyright © 2018 Laura Evans. All rights reserved.
//

import UIKit

class QuizViewController: UIViewController {
    
    var quiz: Quiz?
    var word: Word? {
        didSet {
            if word == nil {
                textLabel.text = "No more words. Quiz is over."
            } else {
                textLabel.text = word?.translation
                translationLabel.text = word?.text
                
                resultStackView.isHidden = true
            }
        }
    }
    var answer: String?
    var initialTouchPoint: CGPoint = CGPoint(x: 0,y: 0)
    
    @IBOutlet weak var textLabel : UILabel!
    @IBOutlet weak var translationLabel : UILabel!
    @IBOutlet weak var resultStackView : UIStackView!
    @IBOutlet weak var resultImage : UIImageView!
    @IBOutlet weak var resultLabel : UILabel!
    
    // Buttons
    @IBOutlet weak var closeButton : UIButton!
    @IBOutlet weak var viewTranslationButton : UIButton!
    @IBOutlet weak var showAnotherButton : UIButton!
    
    // Constraints
    @IBOutlet weak var verticalConstraint: NSLayoutConstraint!
    
    // Text field properties
    @IBOutlet weak var enterAnswerView : UIView!
    @IBOutlet weak var answerTextField : UITextField!
    
    //MARK: - lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
 
        setupQuiz()
        setupPanGesture()
        
        enterAnswerView.isHidden = true
        view.addSubview(enterAnswerView)
        
        translationLabel.isHidden = true
        
        setupKeyboardNotifications()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        enterAnswerView.frame = CGRect(x: 0, y: view.frame.height, width: view.frame.width, height: enterAnswerView.frame.height)
        enterAnswerView.isHidden = false
        answerTextField.becomeFirstResponder()
    }

    //MARK: - outlet action methods
    
    @IBAction func submitAnswerTapped(_ sender: Any) {
        guard let answer = answerTextField.text, answer != "" else { return }
        self.answer = answer
        submitAnswer()
    }
    
    @IBAction func showAnotherWord(_ sender: Any) {
        showAnotherWord()
    }
    
    @IBAction func close(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: - custom methods
    func setupQuiz() {
        quiz = Quiz()
        word = quiz?.pickRandomWord()
    }
    
    
    func showAnotherWord() {
        translationLabel.isHidden = true
        word = quiz?.pickRandomWord()
        answerTextField.becomeFirstResponder()
    }
    
    func viewTranslation() {
        translationLabel.isHidden = false
    }
    
    func submitAnswer() {
        
        guard var quiz = quiz else { return }
        
        guard let answer = self.answer, answer != "" else { return }

        let correct = quiz.submitAnswer(answer: answer)
        
        // If answer is correct
        if correct.0 {
            resultLabel.text = "Correct!"
            resultImage.image = #imageLiteral(resourceName: "checkmark")
            
            // Change tint color of resultImage
            resultImage.image = resultImage.image!.withRenderingMode(.alwaysTemplate)
            resultImage.tintColor = UIColor.white
            
        } else {
            // Answer is wrong
            resultLabel.text = "Incorrect"
            resultImage.image = #imageLiteral(resourceName: "xIcon")
            
            // Change tint color of resultImage
            resultImage.image = resultImage.image!.withRenderingMode(.alwaysTemplate)
            resultImage.tintColor = #colorLiteral(red: 1, green: 0.2779999971, blue: 0.2779999971, alpha: 1)
        }
        
        resultStackView.isHidden = false
        translationLabel.isHidden = false
        
        
        
        answerTextField.resignFirstResponder()
        answerTextField.text = ""
    }
    
    //MARK: - Keyboard methods
    func setupKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow,object: nil
        )
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide,object: nil
        )
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        print("keyboard will show")
        
        if let keyboardFrame: NSValue = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let yPoint = self.view.frame.height - (keyboardRectangle.height + enterAnswerView.frame.height)
            animateEnterAnswerView(yPoint: yPoint)
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        animateEnterAnswerView(yPoint: self.view.frame.height)
    }
    
    func animateEnterAnswerView(yPoint: CGFloat) {
        UIView.animate(withDuration: 0.3) {
            self.enterAnswerView.frame.origin = CGPoint(x: 0, y: yPoint)
        }
    }
}

//MARK: - pan gesture extension
extension QuizViewController {
    
    func setupPanGesture() {
        let gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(swipeDown(gestureRecognizer:)))
        view.addGestureRecognizer(gestureRecognizer)
    }
    
    @objc func swipeDown(gestureRecognizer: UIPanGestureRecognizer) {
        
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
