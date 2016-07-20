//
//  RootViewController.swift
//  EventsApp
//
//  Created by Keith Caffrey on 23/05/2016.
//  Copyright © 2016 KC. All rights reserved.
//

import UIKit
import GoogleAPIClient

class EARootViewController: UIViewController,GIDSignInDelegate {
    
    var loginViewController:EALoginViewController?
    var eaRootSWRevealViewController :SWRevealViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var configureError: NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        if (configureError != nil) {
            print("We have an error! \(configureError)")
        }
        GIDSignIn.sharedInstance().scopes.append(kGTLAuthScopeDrive)
        
        GIDSignIn.sharedInstance().delegate = self
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if(GIDSignIn.sharedInstance().currentUser == nil) {
            GIDSignIn.sharedInstance().signInSilently()
        }
    }
    
    func showLogin(animated:Bool) {
        let storyboard = UIStoryboard(name: "EAMain", bundle: nil)
        loginViewController = (storyboard.instantiateViewControllerWithIdentifier("LoginViewController") as! EALoginViewController)
        self.presentViewController(loginViewController!, animated: true, completion: nil)
    }
    
    
    func showRootSWRevealViewController(animated:Bool) {
        let storyboard = UIStoryboard(name: "EAMain", bundle: nil)
        eaRootSWRevealViewController = (storyboard.instantiateViewControllerWithIdentifier("RootSWRevealViewController") as! SWRevealViewController)
        self.presentViewController(eaRootSWRevealViewController!, animated: true, completion: nil)
    }

    // MARK: GIDSignInDelegate methods
    func signIn(signIn: GIDSignIn!, didSignInForUser user: GIDGoogleUser!, withError error: NSError!) {
        if(error != nil) {
            print("Looks like we got a sign in error \(error)")
            //present the login view controller if not already presented
            if(self.loginViewController == nil) {
                 showLogin(true)
            }
        }
        else {
            print("Wow our user signed in \(user)")
            if (self.loginViewController != nil) {
                weak var weakSelf:EARootViewController? = self;
                self.dismissViewControllerAnimated(true, completion:{
                    weakSelf?.showRootSWRevealViewController(true);
                })
            }
            else {
                showRootSWRevealViewController(true);
            }
            
        }
    }
    
    
    

    
  
}
