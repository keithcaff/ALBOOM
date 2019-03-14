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
    }
    
    @IBAction func c(_ sender: UIStoryboardSegue) {
        print("unWindToImageTabBar")
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        print("EAImageTabBarController view did appear")
    }
}
