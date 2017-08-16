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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if (GIDSignIn.sharedInstance().currentUser == nil || !GIDSignIn.sharedInstance().hasAuthInKeychain()) {
            GIDSignIn.sharedInstance().signInSilently()
            showLogin()
        }
        else {
            showRootSWRevealViewController()
        }
    }
    
    func showLogin() {
        let storyboard = UIStoryboard(name: StoryBoardIdentifiers.MAIN_STORYBOARD, bundle: nil)
        loginViewController = (storyboard.instantiateViewController(withIdentifier: ViewControllerIdentifiers.LOGIN_VIEW_CONTROLLER) as! EALoginViewController)
        if let nav = self.navigationController {
            nav.pushViewController(self.loginViewController!, animated: false)
        }
    }
    
    func showRootSWRevealViewController() {
        let storyboard = UIStoryboard(name: StoryBoardIdentifiers.MAIN_STORYBOARD, bundle: nil)
        eaRootSWRevealViewController = (storyboard.instantiateViewController(withIdentifier: ViewControllerIdentifiers.ROOT_SW_REVEAL_VIEW_CONTROLLER) as! SWRevealViewController)
        if let nav = self.navigationController {
            nav.pushViewController(self.eaRootSWRevealViewController!, animated: false)
        }
    }

    // MARK: GIDSignInDelegate methods
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if(error != nil) {
            print("We got a sign in error: \(error)")
            //present the login view controller if not already presented
            if(self.loginViewController == nil) {
                 showLogin()
            }
        }
        else {
            print("Our user signed in:  \(user)")
            if (self.loginViewController != nil) { //remove the login view controller from the root nav before navigating swreveal vc
                if let nav = self.navigationController {
                    nav.popViewController(animated: false)
                    showRootSWRevealViewController()
                }
            }
            else {
                showRootSWRevealViewController()
            }
        }
    }
}
