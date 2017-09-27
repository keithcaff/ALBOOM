//
//  EAGoogleSignViewController.swift
//  EventsApp
//
//  Created by Keith Caffrey on 22/05/2016.
//  Copyright © 2016 KC. All rights reserved.
//

import UIKit
import GoogleAPIClient

class EALoginViewController: UIViewController, GIDSignInUIDelegate, GIDSignInDelegate{

    @IBOutlet var googleSignInButton: GIDSignInButton!
    @IBOutlet var profilePic: UIImageView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var loginListener:EALoginListener?
        
    override func viewDidLoad() {
        super.viewDidLoad()
        var configureError: NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        if (configureError != nil) {
            print("We have an error! \(configureError)")
        }
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().scopes.append(kGTLAuthScopeDrive)
        GIDSignIn.sharedInstance().delegate = self
        
        googleSignInButton.isHidden = false
        activityIndicator.isHidden = true;

       // refereshInterface()
        // Do any additional setup after loading the view.
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("EALoginViewController did appear")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func signInButtonTapped(_ sender: Any) {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        print("signInButtonClicked")
    }
    
    func refereshInterface() {
        if let currentUser = GIDSignIn.sharedInstance().currentUser {
            self .dismiss(animated: true, completion:nil)
            googleSignInButton.isHidden = true


            let profilePicURL = currentUser.profile.imageURL(withDimension: 175);
            profilePic.image = UIImage(data:try! Data(contentsOf: profilePicURL!))
            profilePic.isHidden = false;
        }
        else {
            googleSignInButton.isHidden = false
            profilePic.isHidden = true;
            profilePic.image = nil;
        }
    }
    
    
    // MARK: GIDSignInDelegate methods
    public func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if(error != nil) {
            print("We got a sign in error: \(error)")
             self.loginListener?.loginFailed()
        }
        else {
            print("Our user signed in:  \(user)")
            self.loginListener?.loginSuccess()
        }
    }
    
    // The sign-in flow has finished selecting how to proceed, and the UI should no longer display
    // a spinner or other "please wait" element.
    public func sign(inWillDispatch signIn: GIDSignIn!, error: Error!) {
        print("EALoginViewController -1 signInWillDispatch" )
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
    }
    
//    // If implemented, this method will be invoked when sign in needs to display a view controller.
//    // The view controller should be displayed modally (via UIViewController's |presentViewController|
//    // method, and not pushed unto a navigation controller's stack.
//    public func sign(_ signIn: GIDSignIn!, present viewController: UIViewController!) {
//         print("EALoginViewController -2 signIn" )
//    }
//    // If implemented, this method will be invoked when sign in needs to dismiss a view controller.
//    // Typically, this should be implemented by calling |dismissViewController| on the passed
//    // view controller.
//    public func sign(_ signIn: GIDSignIn!, dismiss viewController: UIViewController!) {
//        print("EALoginViewController -3 signIn" )
//    }
    
    
}
