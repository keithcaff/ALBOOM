//
//  EACreateEventViewController.swift
//  EventsApp
//
//  Created by Keith Caffrey on 27/05/2016.
//  Copyright © 2016 KC. All rights reserved.
//

import UIKit

class EACreateEventViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var eventNameTextField: UITextField!
    @IBOutlet weak var createEventButton: UIButton!
    
    var event:EAEvent?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        eventNameTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: UIControlEvents.editingChanged)
        eventNameTextField.delegate = self;
        eventNameTextField.text = EAUIText.CREATE_EVENT_TEXTFIELD_PLACEHOLDER
        createEventButton.isEnabled = false
        eventNameTextField.becomeFirstResponder()
        eventNameTextField.attributedPlaceholder = NSAttributedString(string: EAUIText.CREATE_EVENT_TEXTFIELD_PLACEHOLDER, attributes: [NSAttributedStringKey.foregroundColor: EAUIColours.SECONDARY_BLUE])
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("get ready to create event here")
        if segue.identifier == "createEventUnWind" {
            let eventName = eventNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            event = EAEvent(id:nil, eventName: eventName)
        }
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if let text = textField.text {
            let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
            if (trimmedText.count == 0 || trimmedText.count > 30) {
                createEventButtonEnabled(false)
            }
            else {
               createEventButtonEnabled(true)
            }
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentCharacterCount = textField.text?.count ?? 0
        if (range.length + range.location > currentCharacterCount){
            return false
        }
        let newLength = currentCharacterCount + string.count - range.length
        return newLength <= 30
    }
    
    
    func createEventButtonEnabled(_ enabled:Bool) {
        createEventButton.isEnabled = enabled
    }
    
    
}
