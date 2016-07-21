//
//  MenuTableViewController.swift
//  EventsApp
//
//  Created by Keith Caffrey on 26/05/2016.
//  Copyright © 2016 KC. All rights reserved.
//

import UIKit
import GoogleAPIClient
import GTMOAuth2


class EAMenuTableViewController: UITableViewController {
    
    private let service = GTLServiceDrive()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    
    @IBAction func unWindToMenu(sender: UIStoryboardSegue) {
        print("unWindToMenu")
        if(sender.identifier == "createEventUnWind") {
            let source: EACreateEventViewController
            source = sender.sourceViewController as! EACreateEventViewController
            if let event = source.event {
                createEventFolder(event)
            }
        }
    }
    
    func setAuthorizerForService(signIn:GIDSignIn,user:GIDGoogleUser) {
        let auth:GTMOAuth2Authentication = GTMOAuth2Authentication()
        auth.clientID = signIn.clientID
        auth.userEmail = user.profile.email;
        auth.userID = user.userID
        auth.accessToken = user.authentication.accessToken
        auth.refreshToken = user.authentication.refreshToken
        auth.expirationDate = user.authentication.accessTokenExpirationDate
        service.authorizer = auth
    }
    
    
    func createEventFolder(event:EAEvent) {
        setAuthorizerForService(GIDSignIn.sharedInstance(), user: GIDSignIn.sharedInstance().currentUser)
        service.setExactUserAgent(GIDSignIn.sharedInstance().currentUser.userID)
        print("Creating event folder %event")
        let folder:GTLDriveFile =  GTLDriveFile() ;
        folder.name = EVENT_FOLDER_PREFIX+event.name!
        folder.mimeType = "application/vnd.google-apps.folder";
        let query:GTLQueryDrive = GTLQueryDrive.queryForFilesCreateWithObject(folder,uploadParameters:nil)
        
        weak var weakSelf:EAMenuTableViewController! = self
        service.executeQuery(query, completionHandler:  { (ticket, createdFolder , error) -> Void in
            if let error = error {
                print("failed with error: \(error)")
            }
            else {
                print("success crated folder: \(createdFolder)")
                weakSelf.hideMenu()
                //post some notification that an event was created with event name
                NSNotificationCenter.defaultCenter().postNotificationName(NOTIFICATION_EVENT_FOLDER_CREATED, object: createdFolder)
            }
        })
        
      
    }
    
    func hideMenu() {
        revealViewController().revealToggleAnimated(true)
    }
    

}
