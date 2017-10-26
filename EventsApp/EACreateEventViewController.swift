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
        createEventButton.isEnabled = false
        createEventButton.alpha = 0.3
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("get ready to create event here")
        if segue.identifier == "createEventUnWind" {
            event = EAEvent(id:nil, eventName: eventNameTextField.text!)
        }
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if let text = textField.text {
            if (text.characters.count == 0 || text.characters.count > 30) {
                createEventButtonEnabled(false)
            }
            else {
               createEventButtonEnabled(true)
            }
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let currentCharacterCount = textField.text?.characters.count ?? 0
        if (range.length + range.location > currentCharacterCount){
            return false
        }
        let newLength = currentCharacterCount + string.characters.count - range.length
        return newLength <= 30
    }
    
    
    func createEventButtonEnabled(_ enabled:Bool) {
        createEventButton.isEnabled = enabled
        if(enabled) {
              createEventButton.alpha = 1.0
        }
        else {
            createEventButton.alpha = 0.5
        }
    }
    
    
}
