//
//  EAShareEventViewController.swift
//  EventsApp
//
//  Created by Keith Caffrey on 04/01/2018.
//  Copyright © 2018 KC. All rights reserved.
//

import Foundation

class EAShareEventViewController : UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var shareButton: UIButton!
    var selectedEvent:EAEvent!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: UIControlEvents.editingChanged)
        emailTextField.delegate = self;
        shareButton.isEnabled = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavBarTitle()
    }
    
    @IBAction func shareButtonClicked(_ sender: Any) {
        if let text = emailTextField.text {
            let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
            EAGoogleAPIManager.sharedInstance.shareEvent(selectedEvent,withEmail: trimmedText)
        }
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if let text = emailTextField.text {
            let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
            if (trimmedText.count == 0 || trimmedText.count > 60 || !(validEmail(text))) {
                shareButton.isEnabled = false
            }
            else {
                shareButton.isEnabled = true
            }
        }
    }
    
    
    private func setupNavBarTitle() {
        if let name = selectedEvent.name {
            self.title = name
        }
    }
    
    private func validEmail(_ email:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }
}
