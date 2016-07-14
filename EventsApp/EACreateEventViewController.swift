//
//  EACreateEventViewController.swift
//  EventsApp
//
//  Created by Keith Caffrey on 27/05/2016.
//  Copyright © 2016 KC. All rights reserved.
//

import UIKit

class EACreateEventViewController: UIViewController {

    @IBOutlet weak var eventNameTextField: UITextField!
    @IBOutlet weak var createEventButton: UIButton!
    
    var event:Event?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        print("get ready to create event here")
        if segue.identifier == "createEventUnWind" {
            event = Event(eventName: eventNameTextField.text!)
        }
    }
    
    
    
}
