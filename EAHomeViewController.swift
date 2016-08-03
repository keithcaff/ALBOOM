//
//  EAHomeViewController.swift
//  EventsApp
//
//  Created by Keith Caffrey on 26/05/2016.
//  Copyright © 2016 KC. All rights reserved.
//

import UIKit
import GoogleAPIClient
import GTMOAuth2

class EAHomeViewController: UIViewController {
    
    var currentEventFolder:GTLDriveFile?
    var currentFiles:GTLDriveFileList?

    @IBOutlet var menuButton: UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(newEventCreated), name: NOTIFICATION_EVENT_FOLDER_CREATED, object: nil)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(eventFilesRetrieved), name: NOTIFICATION_EVENT_FILES_RETRIEVED, object: nil)

        let defaults = NSUserDefaults.standardUserDefaults()
        if let currentEventName = defaults.stringForKey(DEFAULT_CURRENT_EVENT_NAME) {
            self.navigationController?.navigationBar.topItem?.title = currentEventName
        }

        menuButton.target = revealViewController()
        menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
        
        revealViewController().rightViewRevealWidth = 150
        view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        // Do any additional setup after loading the view.
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        print("currentEventFolder: \(currentEventFolder?.name)")
        EAGoogleAPIManager.sharedInstance.fetchFiles()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK:notifaction responses/selectors
    func newEventCreated(notifiaction : NSNotification) {
        print("new event folder created")
        revealViewController().revealToggleAnimated(true)
        if let folder = notifiaction.object as? GTLDriveFile  {
            currentEventFolder = folder
            self.navigationController?.navigationBar.topItem?.title = folder.name
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setObject(folder.name, forKey: DEFAULT_CURRENT_EVENT_NAME)
        }
    }
    
    func eventFilesRetrieved(notifiaction : NSNotification) {
        print("event files retrieved selector")
        revealViewController().revealToggleAnimated(true)
        if let files = notifiaction.object as? GTLDriveFileList  {
            currentFiles = files
            
        }
    }

    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
}
