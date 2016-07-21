//
//  MenuTableViewController.swift
//  EventsApp
//
//  Created by Keith Caffrey on 26/05/2016.
//  Copyright © 2016 KC. All rights reserved.
//

import UIKit
import GoogleAPIClient
import GTMOAuth2


class EAMenuTableViewController: UITableViewController {
    
    private let service = GTLServiceDrive()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    
    @IBAction func unWindToMenu(sender: UIStoryboardSegue) {
        print("unWindToMenu")
        if(sender.identifier == "createEventUnWind") {
            let source: EACreateEventViewController
            source = sender.sourceViewController as! EACreateEventViewController
            if let event = source.event {
                EAGoogleAPIManager.sharedInstance.createEventFolder(event)
            }
        }
    }
   
    func hideMenu() {
        revealViewController().revealToggleAnimated(true)
    }
}
