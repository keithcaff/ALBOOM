//
//  EAMainViewController.swift
//  EventsApp
//
//  Created by Keith Caffrey on 22/05/2016.
//  Copyright © 2016 KC. All rights reserved.
//

import UIKit
import GoogleAPIClient

open class EAHomeTabBarController: UITabBarController, UITabBarControllerDelegate {
    
    var contentViewController:UIViewController?
    var selectOrCreateEventAlert : UIAlertController?
    override open func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        self.updateContentViewController(0)
        selectOrCreateEventAlert = UIAlertController(title: EAUIText.ALERT_CREATE_OR_SELECT_EVENT_TITLE, message: EAUIText.ALERT_CREATE_OR_SELECT_EVENT_MESSAGE, preferredStyle: UIAlertControllerStyle.alert)
        selectOrCreateEventAlert!.addAction(UIAlertAction(title: "Ok", style: .default, handler:nil))
    }
    
    

    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);
    }
    
    open func updateContentViewController(_ selectedTabIndex:Int) {
        var viewController:UIViewController =  self.viewControllers![selectedTabIndex]
        if viewController.isKind(of: UINavigationController.self) {
            viewController = (viewController as! UINavigationController).viewControllers.first!
        }
        contentViewController = viewController
    }
    
    open func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        let id:String = EAEvent.getCurrentEventId()
        if id.count > 1 {
            return true
        }
        else {
            if let contentView = self.contentViewController {
                contentView.present(self.selectOrCreateEventAlert!, animated: true, completion: nil)
            }
            return false
        }
    }
    
    open override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        let index:Int = tabBar.items!.index(of: item)!
        self.updateContentViewController(index)
    }

}
