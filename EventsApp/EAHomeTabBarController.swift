//
//  EAMainViewController.swift
//  EventsApp
//
//  Created by Keith Caffrey on 22/05/2016.
//  Copyright © 2016 KC. All rights reserved.
//

import UIKit
import GoogleAPIClient

open class EAHomeTabBarController: UITabBarController {

    var contentViewController:AnyObject?
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        self.updateContentViewController(0)
    }
    

    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);
//        let selectedIndex:Int? = self.tabBar.items!.indexOf(self.tabBar.selectedItem!)
//        if let selectedIndex = selectedIndex {
//            if selectedIndex != 1 {
//                self.tabBar.hidden = false;
//            }
//        }
    }
    
    open func updateContentViewController(_ selectedTabIndex:Int) {
        var viewController:UIViewController =  self.viewControllers![selectedTabIndex]
        if viewController.isKind(of: UINavigationController.self) {
            viewController = (viewController as! UINavigationController).viewControllers.first!
        }
        contentViewController = viewController
    }
    
    open override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        let index:Int = tabBar.items!.index(of: item)!
        self.updateContentViewController(index)
    }

}
