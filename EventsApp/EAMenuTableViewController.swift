//
//  MenuTableViewController.swift
//  EventsApp
//
//  Created by Keith Caffrey on 26/05/2016.
//  Copyright © 2016 KC. All rights reserved.
//

import UIKit

class EAMenuTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    
    @IBAction func unWindToMenu(sender: UIStoryboardSegue) {
        print("unWindToMenu")
    
    }
    
    
//    @IBAction func cancelToHomeViewController(segue:UIStoryboardSegue) {
//        NSLog("Dismiss the vc here");
//        if let createEventVC = segue.sourceViewController as? EACreateEventViewController {
//            print("we were present the EACreateEventViewController \(createEventVC)")
//            createEventVC.navigationController?.dismissViewControllerAnimated(true, completion: nil);
//    
//        }
       // self.revealViewController().frontViewController?.popToRootViewControllerAnimated(true)
        
        //this will dismiss the navigation view controller
       // self.presentViewController(revealViewController().frontViewController,animated:false,completion: nil)
        
        
        
//         let EACreateEventViewController createEventvC = segue.sourceViewController as EACreateEventViewController ?
//            createEventVC.dism
        //self.dismissViewControllerAnimated(true, completion:nil)
   // }
    
//    @IBAction func createEvent(segue:UIStoryboardSegue) {
//        NSLog("create event here")
//        //self.dismissViewControllerAnimated(true, completion:nil)
//        
//    }

    

}
