//
//  EAViewEventsViewController.swift
//  EventsApp
//
//  Created by Keith Caffrey on 24/07/2016.
//  Copyright © 2016 KC. All rights reserved.
//

import Foundation
import GoogleAPIClient
import UIKit

public class EAViewEventsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableView: UITableView!
    
    var data:NSMutableArray?
    let viewEventCellIdentifier:String = "VIEW_EVENT_CELL"
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(eventFoldersRetrieved), name: NOTIFICATION_EVENT_FOLDERS_RETRIEVED, object: nil)
        self.tableView.dataSource = self
        self.tableView.delegate = self
        let nib = UINib(nibName: "EAViewEventTableViewCell", bundle:nil)
        self.tableView.registerNib(nib, forCellReuseIdentifier: viewEventCellIdentifier)
    }
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count:Int = 0
        if let data = data {
            count = data.count
        }
        return count;
    }
    
    
    
    public func numberOfRowsInSection(section: Int) -> Int {
       return 1
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:EAViewEventTableViewCell?
        if self.data == nil {
            return EAViewEventTableViewCell()
        }
        cell = tableView.dequeueReusableCellWithIdentifier(viewEventCellIdentifier, forIndexPath: indexPath) as? EAViewEventTableViewCell
        
        let event:EAEvent = (self.data!.objectAtIndex(indexPath.row) as! EAEvent)
        cell!.name.text = event.name!
        return cell!
    }
    
    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        EAGoogleAPIManager.sharedInstance.getAllEventFolders()
    }
    
    func eventFoldersRetrieved(notifiaction : NSNotification) {
        data = NSMutableArray();
        if let object = notifiaction.object {
            let foldersList:GTLDriveFileList = (object as! GTLDriveFileList)
            for folder:AnyObject in foldersList.files {
                let name:String? = (folder as! GTLDriveFile).name
                let event:EAEvent = EAEvent.init(eventName: name!);
                data?.addObject(event)
            }
        }
        self.tableView.reloadData()
    }
    
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    
    
}