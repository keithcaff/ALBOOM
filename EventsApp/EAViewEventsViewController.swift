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
    var selectedEvent:EAEvent?
    
    func unWindToMenu(event:EAEvent) {
        print("selected event \(event.name!)")
        selectedEvent = event
        self.performSegueWithIdentifier(EXIT_VIEW_EVENTS_UNWIND_SEGUE,sender:self);
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(eventFoldersRetrieved), name: NOTIFICATION_EVENT_FOLDERS_RETRIEVED, object: nil)
        self.tableView.dataSource = self
        self.tableView.delegate = self
        let nib = UINib(nibName: "EAViewEventTableViewCell", bundle:nil)
        self.tableView.registerNib(nib, forCellReuseIdentifier: viewEventCellIdentifier)
    }
    
    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        EAGoogleAPIManager.sharedInstance.getAllEventFolders()
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK:notifaction responses
    func eventFoldersRetrieved(notifiaction : NSNotification) {
        data = NSMutableArray();
        if let object = notifiaction.object {
            let foldersList:GTLDriveFileList = (object as! GTLDriveFileList)
            for folder:AnyObject in foldersList.files {
                let name:String? = (folder as! GTLDriveFile).name
                let id:String? = (folder as! GTLDriveFile).identifier
                let event:EAEvent = EAEvent.init(id:id!, eventName: name!);
                data?.addObject(event)
            }
        }
        self.tableView.reloadData()
    }

    // MARK:Tableview delegates
    
    
    public func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        weak var weakSelf:EAViewEventsViewController! = self
        let delete = UITableViewRowAction(style: .Destructive, title: "Delete") { (action, indexPath) in
            if let data = weakSelf.data {
                let event:EAEvent = data.objectAtIndex(indexPath.row) as! EAEvent
                print("KCTEST: id \(event.id!)")
            }
        }
        
        return [delete]
    }
    
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("selected row \(indexPath.row)")
    }
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count:Int = 0
        if let data = data {
            count = data.count
        }
        return count;
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:EAViewEventTableViewCell?
        if self.data == nil {
            return EAViewEventTableViewCell()
        }
        let event:EAEvent = (self.data!.objectAtIndex(indexPath.row) as! EAEvent)
        cell = tableView.dequeueReusableCellWithIdentifier(viewEventCellIdentifier, forIndexPath: indexPath) as? EAViewEventTableViewCell
        cell?.event = event
        cell?.unWindCallback = unWindToMenu;
        cell!.name.text = event.name!
        cell?.selectionStyle = .None
        return cell!
    }
    
    public func numberOfRowsInSection(section: Int) -> Int {
        return 1
    }
    
    
}