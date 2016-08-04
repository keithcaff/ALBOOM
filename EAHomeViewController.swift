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

public class EAHomeViewController: UIViewController,UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet var tableView: UITableView!
    var currentEventFolder:GTLDriveFile?
    var currentFiles:GTLDriveFileList?

    @IBOutlet var menuButton: UIBarButtonItem!
    override public func viewDidLoad() {
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
        
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        let nib = UINib(nibName: NIB_HOME_CELL_IDENFIER, bundle:nil)
        self.tableView.registerNib(nib, forCellReuseIdentifier: CELL_VIEW_EVENT_IDENTIFIER)
        
    }
    
    override public func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        print("currentEventFolder: \(currentEventFolder?.name)")
        EAGoogleAPIManager.sharedInstance.fetchFiles()
        
    }

    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK:Tableview delegates
    
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("selected row \(indexPath.row)")
    }
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count:Int = 0
        if let data = currentFiles?.files {
            count = data.count
        }
        return count;
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:EAHomeTableViewCell?
        if (self.currentFiles?.files == nil || self.currentFiles?.files?.count < 1){
            return EAHomeTableViewCell()
        }
        
        let currentFiles:NSArray? = self.currentFiles?.files
        var file:GTLDriveFile?
        if let files = currentFiles{
            file = (files.objectAtIndex(indexPath.row) as! GTLDriveFile)
        }
        
        cell = tableView.dequeueReusableCellWithIdentifier(CELL_HOME_IDENTIFIER, forIndexPath: indexPath) as? EAHomeTableViewCell
        if let name:String = file?.name {
            cell?.imageTitleLabel.text = name
        }
        return cell!
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
