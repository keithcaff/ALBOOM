//
//  EACreateEventViewController.swift
//  EventsApp
//
//  Created by Keith Caffrey on 27/05/2016.
//  Copyright © 2016 KC. All rights reserved.
//

import UIKit

class EACreateEventViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    

    @IBAction func cancelButtonClicked(sender: AnyObject) {
        
        //self.navigationController?.popToRootViewControllerAnimated(true);
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        print("get ready to create event here")
        segue.destinationViewController as! EAMenuTableViewController
    }
    


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}