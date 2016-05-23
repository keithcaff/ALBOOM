//
//  EAGoogleSignViewController.swift
//  EventsApp
//
//  Created by Keith Caffrey on 22/05/2016.
//  Copyright © 2016 KC. All rights reserved.
//

import UIKit

class EALoginViewController: UIViewController, GIDSignInUIDelegate{

    @IBOutlet var welcomeLabel: UILabel!
    @IBOutlet var signOutButton: UIButton!
    @IBOutlet var googleSignInButton: GIDSignInButton!
    @IBOutlet var profilePic: UIImageView!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance().uiDelegate = self
        profilePic.hidden = true;
        googleSignInButton.hidden = false
        signOutButton.hidden = true
        welcomeLabel.hidden = false;
       // refereshInterface()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func signOutWasPressed(sender: AnyObject) {
        GIDSignIn.sharedInstance().signOut()
        //refereshInterface()
    }
    
    func refereshInterface() {
        if let currentUser = GIDSignIn.sharedInstance().currentUser {
            self .dismissViewControllerAnimated(true, completion:nil)
            googleSignInButton.hidden = true
            signOutButton.hidden = false
            welcomeLabel.text = "Welcome, \(currentUser.profile.name)!"
            let profilePicURL = currentUser.profile.imageURLWithDimension(175);
            profilePic.image = UIImage(data:NSData(contentsOfURL:profilePicURL)!)
            profilePic.hidden = false;
        }
        else {
            googleSignInButton.hidden = false
            signOutButton.hidden = true
            welcomeLabel.hidden = false
            welcomeLabel.text = "Sign in, stranger!"
            profilePic.hidden = true;
            profilePic.image = nil;
        }
    }
}
