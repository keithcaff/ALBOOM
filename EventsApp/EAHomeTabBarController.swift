//
//  EAMainViewController.swift
//  EventsApp
//
//  Created by Keith Caffrey on 22/05/2016.
//  Copyright © 2016 KC. All rights reserved.
//

import UIKit
import GoogleAPIClient

public class EAHomeTabBarController: UITabBarController {

    var contentViewController:AnyObject?
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.updateContentViewController(0)
        //(UIApplication.sharedApplication().delegate as! AppDelegate).signInCallBack = refereshInterface
        
        // Do any additional setup after loading the view.
    }
    

    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    func refereshInterface() {
//        if (GIDSignIn.sharedInstance().currentUser == nil) {
//          showLogin(true);
//        }
//    }
    
    
    public func updateContentViewController(selectedTabIndex:Int) {
        var viewController:UIViewController =  self.viewControllers![selectedTabIndex]
        if viewController.isKindOfClass(UINavigationController) {
            viewController = (viewController as! UINavigationController).viewControllers.first!
        }
        contentViewController = viewController
    }
    
    
    
    public override func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
        self.updateContentViewController(self.selectedIndex)
    }
    
    func showLogin(animated:Bool) {
        let storyboard = UIStoryboard(name: "EAMain", bundle: nil)
        let signInViewControler:EALoginViewController = storyboard.instantiateViewControllerWithIdentifier("LoginViewController") as! EALoginViewController
        self.presentViewController(signInViewControler, animated: true, completion: nil)
    }

}
