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
import UIColor_Hex

open class EAHomeViewController: UIViewController,UITableViewDelegate, UITableViewDataSource, EAEventUpdateDelegate{
    
    @IBOutlet var tableView: UITableView!
    var currentEventFolder:GTLDriveFile?
    var currentFilesList:GTLDriveFileList?
    var fileDataMap:Dictionary = Dictionary<String, Data>()
    let homeCellReuseIdentifier:String = "eaHomeTableViewCell"
    let UIImageViewTagId = 303

    @IBOutlet var menuButton: UIBarButtonItem!
    override open func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(newEventCreated), name: .NOTIFICATION_EVENT_FOLDER_CREATED, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(eventFileDownloaded), name: .NOTIFICATION_EVENT_FILE_DOWNLOADED, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(eventDeleted), name: .NOTIFICATION_EVENT_FOLDER_DELETED, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(eventFilesRetrieved), name: .NOTIFICATION_EVENT_FILES_RETRIEVED, object: nil)

        let defaults = UserDefaults.standard
        if let currentEventName = defaults.string(forKey: DEFAULT_CURRENT_EVENT_NAME) {
            self.navigationController?.navigationBar.topItem?.title = currentEventName
        }

        menuButton.target = revealViewController()
        menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
        
        revealViewController().rightViewRevealWidth = 150
        view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        self.tableView.estimatedRowHeight = 545
        let nib = UINib(nibName: XIBIdentifiers.XIB_VIEW_EVENT_CELL_IDENTIFIER, bundle:nil)
        self.tableView.register(nib, forCellReuseIdentifier: homeCellReuseIdentifier)
        
    }
    
    
    func didSwitchEvent(_ event:EAEvent?) {
        EAEvent.didSwitchEvent(event)
        resetHomeViewController()
    }
    
    @IBAction func unWindToHomeViewController(_ sender: UIStoryboardSegue) {
        print("unWindToHomeViewController")
        self.tabBarController?.tabBar.isHidden = false;
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }

    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
       
    func addBackground(_ cell:EAHomeTableViewCell, file:GTLDriveFile!) {
        let view:UIView = cell.placeHolderView
        // screen width and height:
        let width = view.bounds.size.width
        let height = view.bounds.size.height
        var bgImage:UIImage?
        var imageViewBackground:UIImageView?
        
        if let file = file {
            let fileData:Data? = self.fileDataMap[file.identifier]
            if let fileData = fileData {
                bgImage = UIImage(data: fileData)
                activityIndicatorVisible(false, cell:cell)
                if let view = view.viewWithTag(UIImageViewTagId) {
                    imageViewBackground = view as? UIImageView
                }
                else {
                    imageViewBackground = UIImageView(frame: CGRect(x: 0, y: 0, width: width, height: height))
                    imageViewBackground?.tag = UIImageViewTagId
                    // you can change the content mode:
                    imageViewBackground?.contentMode = UIViewContentMode.scaleToFill
                    imageViewBackground?.translatesAutoresizingMaskIntoConstraints = false;
                    view.addSubview(imageViewBackground!)
                    let top = NSLayoutConstraint(item: imageViewBackground!, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem:view , attribute: NSLayoutAttribute.top, multiplier: 1, constant: 0)
                    let bottom = NSLayoutConstraint(item: imageViewBackground!, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem:view , attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 0)
                    let leading = NSLayoutConstraint(item: imageViewBackground!, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem:view , attribute: NSLayoutAttribute.leading, multiplier: 1, constant: 0)
                    let trailing = NSLayoutConstraint(item: imageViewBackground!, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem:view , attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: 0)
                    view.addConstraint(top)
                    view.addConstraint(bottom)
                    view.addConstraint(leading)
                    view.addConstraint(trailing)
                    view.sendSubview(toBack: imageViewBackground!)
                }
                imageViewBackground?.image = bgImage
            }
            else {
                if let view = view.viewWithTag(UIImageViewTagId) {
                    imageViewBackground = view as? UIImageView
                    imageViewBackground?.image = nil
                }
                self.activityIndicatorVisible(true, cell:cell)
            }
        }
    }
    
    // MARK:Tableview delegates
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count:Int = 0
        if let data = currentFilesList?.files {
            count = data.count
        }
        return count;
    }

    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell:EAHomeTableViewCell?
        if (self.currentFilesList?.files == nil || self.currentFilesList!.files.count < 1){
            return EAHomeTableViewCell()
        }
        
        let currentFilesList:NSArray? = self.currentFilesList!.files as NSArray?
        var file:GTLDriveFile?
        if let files = currentFilesList{
            file = (files.object(at: indexPath.row) as! GTLDriveFile)
        }
        
        cell = tableView.dequeueReusableCell(withIdentifier: homeCellReuseIdentifier, for: indexPath) as? EAHomeTableViewCell
        cell?.imageTitleLabel.text = file?.name
        
        if (self.currentFilesList?.files.indices.contains(indexPath.row) != nil) {
            addBackground(cell!, file: (self.currentFilesList?.files[indexPath.row] as! GTLDriveFile))
        }
        return cell!
    }
    
    
    
    
    func activityIndicatorVisible(_ visible:Bool, cell:EAHomeTableViewCell!) {
        cell.activityIndicatorContainerView.isHidden = !visible
        
        if(visible) {
           cell.activityIndicator.startAnimating()
        }
    }
    
    
    open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        let topNavHeight:CGFloat = self.navigationController!.navigationBar.frame.height
        let bottomNavHeight:CGFloat =  self.tabBarController!.tabBar.frame.height
        let statusBarHeight:CGFloat = UIApplication.shared.statusBarFrame.size.height
        let navHeight:CGFloat = topNavHeight+bottomNavHeight+statusBarHeight
        return self.tableView.frame.height-navHeight
    }
    
    // MARK:notifaction responses/selectors
    func eventFileDownloaded(_ notifiaction : Notification) {
        print("event file downloaded")
        var fileId:String?
        if let fileData = notifiaction.object as? Data  {
            fileId = (notifiaction.userInfo!["fileId"] as! String)
            fileDataMap[fileId!] = fileData
        }
        var fileIndex:Int?
        if let currentFilesList = currentFilesList {
            for (index, element) in currentFilesList.files.enumerated() {
                if (element as! GTLDriveFile).identifier == fileId! {
                    fileIndex = index
                }
            }
            
            if let fileIndex = fileIndex {
                let index:IndexPath = IndexPath(row:fileIndex, section:0)
                self.tableView.reloadRows(at: [index], with: UITableViewRowAnimation.none)
            }
        }
    }
    
    func newEventCreated(_ notifiaction : Notification) {
        print("new event folder created")
        revealViewController().revealToggle(animated: true)
        if let folder = notifiaction.object as? GTLDriveFile  {
            currentEventFolder = folder
            updateNavBarTitle(folder.name)
            let defaults = UserDefaults.standard
            defaults.set(folder.name!, forKey: DEFAULT_CURRENT_EVENT_NAME)
            defaults.set(folder.identifier!, forKey: DEFAULT_CURRENT_EVENT_ID)
            let createdEvent:EAEvent = EAEvent(id: folder.identifier!,eventName: folder.name!)
            self.didSwitchEvent(createdEvent)
            resetHomeViewController()
        }
    }
    
    func eventDeleted(_ notifiaction : Notification) {
        let defaults = UserDefaults.standard
        let currentEventId:String = defaults.string(forKey: DEFAULT_CURRENT_EVENT_ID)!
        if let event:EAEvent = notifiaction.object as? EAEvent, event.id == currentEventId {
            resetHomeViewController()
        }
    }

    func eventFilesRetrieved(_ notifiaction : Notification) {
        print("event files retrieved selector")
        revealViewController().revealToggle(animated: true)
        if let fileList = notifiaction.object as? GTLDriveFileList  {
            currentFilesList = fileList
            self.tableView.reloadData()
            for file in fileList.files {
                EAGoogleAPIManager.sharedInstance.downloadFile(file as! GTLDriveFile)
            }
        }
    }
    
    func resetHomeViewController() {
        self.currentFilesList = nil
        currentEventFolder = nil
        self.fileDataMap = Dictionary<String, Data>()
        let defaults = UserDefaults.standard
        let name:String = defaults.string(forKey: DEFAULT_CURRENT_EVENT_NAME)!
        updateNavBarTitle(name)
        self.tableView.reloadData()
    }
    
    func updateNavBarTitle(_ title:String) {
        self.navigationController?.navigationBar.topItem?.title = title
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
}