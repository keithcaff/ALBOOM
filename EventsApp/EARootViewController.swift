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
    var homeViewController:EAHomeViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var configureError: NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        if (configureError != nil) {
            print("We have an error! \(configureError)")
        }
        GIDSignIn.sharedInstance().scopes.append(kGTLAuthScopeDriveAppdata)
        GIDSignIn.sharedInstance().delegate = self
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        GIDSignIn.sharedInstance().signInSilently()
    }
    
    func showLogin(animated:Bool) {
        let storyboard = UIStoryboard(name: "EAMain", bundle: nil)
        loginViewController = (storyboard.instantiateViewControllerWithIdentifier("LoginViewController") as! EALoginViewController)
        self.presentViewController(loginViewController!, animated: true, completion: nil)
    }
    
    
    func showHomeViewController(animated:Bool) {
        let storyboard = UIStoryboard(name: "EAMain", bundle: nil)
        homeViewController = (storyboard.instantiateViewControllerWithIdentifier("HomeViewController") as! EAHomeViewController)
        self.presentViewController(homeViewController!, animated: true, completion: nil)
    }

    // MARK: GIDSignInDelegate methods
    func signIn(signIn: GIDSignIn!, didSignInForUser user: GIDGoogleUser!, withError error: NSError!) {
        if(error != nil) {
            print("Looks like we got a sign in error \(error)")
            //present the login view controller
            showLogin(true)
        }
        else {
            print("Wow our user signed in \(user)")
            if (self.loginViewController != nil) {
                weak var weakSelf:EARootViewController? = self;
                self.dismissViewControllerAnimated(true, completion:{
                self.showHomeViewController(true)
                    weakSelf?.showHomeViewController(true);
                })
            }
            else {
                showHomeViewController(true);
            }
            
        }
    }
    
    
    

    
  
}
