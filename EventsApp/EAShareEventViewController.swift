//
//  EAShareEventViewController.swift
//  EventsApp
//
//  Created by Keith Caffrey on 04/01/2018.
//  Copyright © 2018 KC. All rights reserved.
//

import Foundation

class EAShareEventViewController : UIViewController, UITextFieldDelegate {

    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var shareButton: UIButton!
    var selectedEvent:EAEvent!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: UIControlEvents.editingChanged)
        emailTextField.delegate = self;
        infoLabel.text = EAUIText.SHARE_EVENT_INFO_TEXT
        shareButton.isEnabled = false
        setupNotifications()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavBarTitle()
    }
    
    @IBAction func shareButtonClicked(_ sender: Any) {
        if let text = emailTextField.text {
            let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
            activityIndicator.startAnimating()
            EAGoogleAPIManager.sharedInstance.shareEvent(selectedEvent,withEmail: trimmedText)
            shareButton.isEnabled = false
        }
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        shareButton.isEnabled = shouldEnableShareButtonForTextField(textField)
    }
    
    
    func shouldEnableShareButtonForTextField(_ textField:UITextField) -> Bool {
        var enabled = false
        if let text = emailTextField.text {
            let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmedText.count > 0 && trimmedText.count < 70 && validEmail(text) && !self.activityIndicator.isAnimating {
                enabled = true
            }
        }
        return enabled
    }
    
    private func setupNavBarTitle() {
        if let name = selectedEvent.name {
            self.title = name
        }
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(eventSharedSuccessfully), name: .NOTIFICATION_EVENT_FOLDER_SHARED, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(eventShareFailed), name: .NOTIFICATION_EVENT_SHARE_FAILED, object: nil)
    }
    
    @objc func eventSharedSuccessfully(_ notifiaction : Notification) {
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
            let alert = UIAlertController(title: EAUIText.ALERT_EVENT_SHARED_SUCCESSFULLY_TITLE, message: EAUIText.ALERT_EVENT_SHARED_SUCCESSFULLY_MESSAGE, preferredStyle: UIAlertControllerStyle.alert)
            let okAction = UIAlertAction(title: EAUIText.ALERT_OK_ACTION_TITLE, style: UIAlertActionStyle.default, handler:
            { action in
                    self.dismiss(animated: true, completion: nil)
            })
            alert.addAction(okAction)
            self.present(alert, animated: true, completion:nil)
        }
    }
    
    @objc func eventShareFailed(_ notification : Notification) {
        DispatchQueue.main.async {
            var message:String?
            if let errorDesc = notification.object as? String {
                    message = "\(EAUIText.ALERT_SHARE_EVENT_FAILED_MESSAGE): \(errorDesc)"
            }else {
                message = "\(EAUIText.ALERT_SHARE_EVENT_FAILED_MESSAGE)"
            }
            self.activityIndicator.stopAnimating()
            let alert = UIAlertController(title: EAUIText.ALERT_SHARE_EVENT_FAILED_TITLE, message: message, preferredStyle: UIAlertControllerStyle.alert)
            let okAction = UIAlertAction(title: EAUIText.ALERT_OK_ACTION_TITLE, style: UIAlertActionStyle.default, handler: nil)
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: ({
                self.shareButton.isEnabled = self.shouldEnableShareButtonForTextField(self.emailTextField)
            }))
        }
        
    }
    
    private func validEmail(_ email:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }
}
