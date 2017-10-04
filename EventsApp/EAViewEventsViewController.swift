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

open class EAViewEventsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableView: UITableView!
    
    var data:NSMutableArray?
    let viewEventCellIReuseIdentifier:String = "VIEW_EVENT_CELL"
    var selectedEvent:EAEvent?
    
    func unWindToMenu(_ event:EAEvent) {
        print("selected event \(event.name!)")
        selectedEvent = event
        self.performSegue(withIdentifier: SegueIdentifiers.EXIT_VIEW_EVENTS_UNWIND_SEGUE,sender:self);
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(eventFoldersRetrieved), name: .NOTIFICATION_EVENT_FOLDERS_RETRIEVED, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(eventFolderDeleted), name: .NOTIFICATION_EVENT_FOLDER_DELETED, object: nil)
        self.tableView.dataSource = self
        self.tableView.delegate = self
        let nib = UINib(nibName: XIBIdentifiers.XIB_VIEW_EVENT_CELL_IDENTIFIER, bundle:nil)
        self.tableView.register(nib, forCellReuseIdentifier: viewEventCellIReuseIdentifier)
    }
    
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        EAGoogleAPIManager.sharedInstance.getAllEventFolders()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK:notifaction responses
    func eventFoldersRetrieved(_ notifiaction : Notification) {
        data = NSMutableArray();
        if let object = notifiaction.object {
            let foldersList:GTLDriveFileList = (object as! GTLDriveFileList)
            for folder:Any in foldersList.files {
                let name:String? = (folder as! GTLDriveFile).name
                let id:String? = (folder as! GTLDriveFile).identifier
                let event:EAEvent = EAEvent.init(id:id!, eventName: name!);
                data?.add(event)
            }
        }
        self.tableView.reloadData()
    }
    
    func eventFolderDeleted(_ notifiaction : Notification) {
        if let event:EAEvent = notifiaction.object as? EAEvent {
            print("need to delete folder from table here \(event)")
            data?.remove(event)
            self.tableView.reloadData()
        }
    }


    // MARK:Tableview delegates
    open func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        weak var weakSelf:EAViewEventsViewController! = self
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            if let data = weakSelf.data {
                let event:EAEvent = data.object(at: indexPath.row) as! EAEvent
                EAGoogleAPIManager.sharedInstance.deleteEvent(event)
            }
        }
        return [delete]
    }
    
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let event:EAEvent =  data?.object(at: indexPath.row) as! EAEvent
        unWindToMenu(event)
        print("selected row \(indexPath.row)")
    }
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count:Int = 0
        if let data = data {
            count = data.count
        }
        return count;
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell:EAViewEventTableViewCell?
        if self.data == nil {
            return EAViewEventTableViewCell()
        }
        let event:EAEvent = (self.data!.object(at: indexPath.row) as! EAEvent)
        cell = tableView.dequeueReusableCell(withIdentifier: viewEventCellIReuseIdentifier, for: indexPath) as? EAViewEventTableViewCell
        cell?.event = event
        cell?.unWindCallback = unWindToMenu;
        cell!.name.text = event.name!
        cell?.selectionStyle = .none
        return cell!
    }
    
}
