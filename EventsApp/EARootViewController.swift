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
        NotificationCenter.default.addObserver(self, selector: #selector(userUnAuthenticated), name: .NOTIFICATION_USER_UNAUTHENTICATED, object: nil)
        
        
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
            createAndShowLoginViewController()
        }
        else {
            showRootSWRevealViewController()
        }
    }
    
    func createAndShowLoginViewController() {
        var loginVCOnStack:Bool = false
        
        if let nav = self.navigationController, let loginVc = self.loginViewController {
            loginVCOnStack = nav.viewControllers.contains(loginVc)
        }
        
        if !(loginVCOnStack) {
            let storyboard = UIStoryboard(name: StoryBoardIdentifiers.MAIN_STORYBOARD, bundle: nil)
            loginViewController = (storyboard.instantiateViewController(withIdentifier: ViewControllerIdentifiers.LOGIN_VIEW_CONTROLLER) as! EALoginViewController)
            if let nav = self.navigationController {
                nav.pushViewController(self.loginViewController!, animated: false)
            }
        }
    }
    
    func showRootSWRevealViewController() {
        let storyboard = UIStoryboard(name: StoryBoardIdentifiers.MAIN_STORYBOARD, bundle: nil)
        eaRootSWRevealViewController = (storyboard.instantiateViewController(withIdentifier: ViewControllerIdentifiers.ROOT_SW_REVEAL_VIEW_CONTROLLER) as! SWRevealViewController)
        var swREvealViewControllerOnStack:Bool = false
        
        
        if let nav = self.navigationController {
            nav.viewControllers.forEach { viewController in
                if viewController.isKind(of:SWRevealViewController.self) {
                    swREvealViewControllerOnStack = true
                }
            }
            if (!swREvealViewControllerOnStack) {
                nav.pushViewController(self.eaRootSWRevealViewController!, animated: false)
            }
        }
    }
    
    func pushViewControllerOnTop(_ viewController:UIViewController!) {
        
        //TODO:check if view controller is already on stack before pushing
        if let nav = self.navigationController {
            nav.pushViewController(viewController, animated: false)
        }
    }
 
    // MARK: GIDSignInDelegate methods
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if(error != nil) {
            print("We got a sign in error: \(error)")
            //present the login view controller if not already presented
            if(self.loginViewController == nil) {
                createAndShowLoginViewController()
            }
            else {
                //Push login vc when user has been aunthenticated/timed out
                self.pushViewControllerOnTop(self.loginViewController)
            }
        }
        else {
            print("Our user signed in:  \(user)")
            if (self.loginViewController != nil) { //remove the login view controller from the root nav before navigating swreveal vc
                if let nav = self.navigationController {
                    if (nav.viewControllers.contains(self.loginViewController!)) {
                        nav.popViewController(animated: false)
                        showRootSWRevealViewController()
                    }
                    else {
                        self.loginViewController?.dismiss(animated: false, completion: nil)
                    }
                }
            }
            else {
                showRootSWRevealViewController()
            }   
        }
    }
    
    //MARK: Notifcation Handlers
    func userUnAuthenticated() {
        if let nav = self.navigationController {
            let topVC = nav.topViewController
            var presentedViewController:UIViewController? = topVC?.presentedViewController
            var lastPresentedVC:UIViewController?
            
            while presentedViewController?.presentedViewController != nil {
                lastPresentedVC = presentedViewController
                presentedViewController = presentedViewController?.presentedViewController
            }
            
            self.loginViewController?.modalPresentationStyle = .overCurrentContext
            lastPresentedVC = lastPresentedVC != nil ? lastPresentedVC : presentedViewController
            lastPresentedVC?.present(self.loginViewController!, animated: false, completion: nil)
        }
    }
}
