//
//  EAImageTabBarController.swift
//  EventsApp
//
//  Created by Keith Caffrey on 10/08/2016.
//  Copyright © 2016 KC. All rights reserved.
//

import Foundation
open class EAImageTabBarController:UITabBarController {
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    @IBAction func unWindToImageTabBar(_ sender: UIStoryboardSegue) {
        print("unWindToImageTabBar")
        //self.dismissViewControllerAnimated(false, completion:nil)
    }
}
