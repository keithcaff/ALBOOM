//
//  EAMainViewController.swift
//  EventsApp
//
//  Created by Keith Caffrey on 22/05/2016.
//  Copyright © 2016 KC. All rights reserved.
//

import UIKit
import GoogleAPIClient

class EAHomeTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        //(UIApplication.sharedApplication().delegate as! AppDelegate).signInCallBack = refereshInterface
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    func refereshInterface() {
//        if (GIDSignIn.sharedInstance().currentUser == nil) {
//          showLogin(true);
//        }
//    }
    
    
    
    func showLogin(animated:Bool) {
        let storyboard = UIStoryboard(name: "EAMain", bundle: nil)
        let signInViewControler:EALoginViewController = storyboard.instantiateViewControllerWithIdentifier("LoginViewController") as! EALoginViewController
        self.presentViewController(signInViewControler, animated: true, completion: nil)
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