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
        if (sender.identifier == "createEventUnWind") {
            let source: EACreateEventViewController
            source = sender.sourceViewController as! EACreateEventViewController
            if let event = source.event {
                EAGoogleAPIManager.sharedInstance.createEventFolder(event)
            }
        }
        if (sender.identifier == EXIT_VIEW_EVENTS_UNWIND_SEGUE) {
            print("exitViewEventsUnwindSegue")
            let source: EAViewEventsViewController
            
            // Clear current files on home vc here..
            let homeTabBarController:EAHomeTabBarController = (revealViewController().frontViewController as! EAHomeTabBarController)
            var contentVC:UIViewController = homeTabBarController.viewControllers!.first!
            if(contentVC.isKindOfClass(UINavigationController)) {
                contentVC = (contentVC as! UINavigationController).viewControllers[0]
            }
            print("content vc is \(contentVC)")
            
            source = sender.sourceViewController as! EAViewEventsViewController
            if let event = source.selectedEvent {
                if let contentVC = contentVC as? EAEventUpdateDelegate {
                    contentVC.didSwitchEvent(event)
                }
                EAGoogleAPIManager.sharedInstance.switchEventFolder(event)
            }
        }
    }
   
    func hideMenu() {
        revealViewController().revealToggleAnimated(true)
    }
}
