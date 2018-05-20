//
//  RootViewController.swift
//  EventsApp
//
//  Created by Keith Caffrey on 23/05/2016.
//  Copyright © 2016 KC. All rights reserved.
//

import UIKit
import GoogleAPIClient

public protocol EALoginListener : NSObjectProtocol {
    func loginSuccess()
    func loginFailed()
}

class EARootViewController: UIViewController, EALoginListener {
    var unAuthorisedAlert:UIAlertController!
    var loginViewController:EALoginViewController?
    var eaRootSWRevealViewController :SWRevealViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(userUnAuthenticated), name: .NOTIFICATION_USER_UNAUTHENTICATED, object: nil)
        EAEvent.didSwitchEvent(nil) //fail safe to remove user defaults if app was forcefully killed
        unAuthorisedAlert = UIAlertController(title: EAUIText.ALERT_UNAUTHORISED_TITLE, message: EAUIText.ALERT_UNAUTHORISED_MESSAGE, preferredStyle: UIAlertControllerStyle.alert)
        unAuthorisedAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler:nil))
        GIDSignIn.sharedInstance().signOut()
        print("EARootViewController - viewDidLoad() called \(Date())")
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if (GIDSignIn.sharedInstance().currentUser == nil || !GIDSignIn.sharedInstance().hasAuthInKeychain()) {
            //GIDSignIn.sharedInstance().signInSilently()
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
            loginViewController?.loginListener = self
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
        if let nav = self.navigationController {
            nav.pushViewController(viewController, animated: false)
        }
    }
 
    //MARK: Notifcation Handlers
    @objc func userUnAuthenticated() {
        GIDSignIn.sharedInstance().signOut()
        EAEvent.didSwitchEvent(nil)
        
        DispatchQueue.main.async {
            if let nav = self.navigationController, let loginVc = self.loginViewController {
                let popToRoot = {
                    nav.popToViewController(loginVc, animated: true)
                    loginVc.present(self.unAuthorisedAlert, animated: true, completion: nil)
                }
                nav.viewControllers.forEach { viewController in
                    if let swReveal =  viewController as? SWRevealViewController {
                        if let presentedVC = swReveal.presentedViewController  {
                            presentedVC.dismiss(animated: true, completion: {
                               popToRoot()
                            })
                        }
                        else {
                           popToRoot()
                        }
                    }
                }
            }
        }
    }
    
    func loginSuccess() {
        showRootSWRevealViewController()
    }
    
    func loginFailed() {
         print("Login failed")
    }
    
}


extension UINavigationController {
    override open var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        
        return [.portrait]
    }
}


extension UITabBarController {
    override open var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        
        return [.portrait]
    }
}
