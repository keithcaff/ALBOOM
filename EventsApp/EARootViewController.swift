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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if (GIDSignIn.sharedInstance().currentUser == nil || !GIDSignIn.sharedInstance().hasAuthInKeychain()) {
            //GIDSignIn.sharedInstance().signInSilently()
            showLogin(false)
        }
        else {
            showRootSWRevealViewController(false)
        }
    }
    
    func showLogin(_ animated:Bool) {
        let storyboard = UIStoryboard(name: "EAMain", bundle: nil)
        loginViewController = (storyboard.instantiateViewController(withIdentifier: "LoginViewController") as! EALoginViewController)
        if let nav = self.navigationController {
            nav.pushViewController(self.loginViewController!, animated: false)
        }
    }
    
    
    func showRootSWRevealViewController(_ animated:Bool) {
        let storyboard = UIStoryboard(name: "EAMain", bundle: nil)
        eaRootSWRevealViewController = (storyboard.instantiateViewController(withIdentifier: "RootSWRevealViewController") as! SWRevealViewController)
        if let nav = self.navigationController {
            nav.pushViewController(self.eaRootSWRevealViewController!, animated: false)
        }
    }

    // MARK: GIDSignInDelegate methods
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if(error != nil) {
            print("Looks like we got a sign in error \(error)")
            //present the login view controller if not already presented
            if(self.loginViewController == nil) {
                 showLogin(true)
            }
        }
        else {
            print("Wow our user signed in \(user)")
            if (self.loginViewController != nil) { //remove the login view controller from the root nav before navigating swreveal vc
                if let nav = self.navigationController {
                    nav.popViewController(animated: false)
                    showRootSWRevealViewController(true)
                }
            }
            else {
                showRootSWRevealViewController(true)
            }
        }
    }
    
  
}
