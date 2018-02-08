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
    
    @IBOutlet weak var homeActionButton: UIButton!
    @IBOutlet var tableView: UITableView!
    private var currentEventFolder:GTLDriveFile?
    private var currentFilesList:GTLDriveFileList?
    private var downlaodsInProgress:[String] = [String]()
    private let homeCellReuseIdentifier:String = "eaHomeTableViewCell"
    private var rootFolder:String?
    private let UIImageViewTagId = 303
    private let refreshControl = UIRefreshControl()
    private var currentEvent:EAEvent?
    @IBOutlet var menuButton: UIBarButtonItem!
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        homeActionButton.setTitle(EAUIText.EAHOME_ACTION_BUTTON_TITLE, for:.normal)
        setupNotifications()
        setupSlider()
        setupTableView()
    }
    
    func setupNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(newEventCreated), name: .NOTIFICATION_EVENT_FOLDER_CREATED, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(eventFileDownloaded), name: .NOTIFICATION_EVENT_FILE_DOWNLOADED, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(eventDeleted), name: .NOTIFICATION_EVENT_FOLDER_DELETED, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(eventFilesRetrieved), name: .NOTIFICATION_EVENT_FILES_RETRIEVED, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(latestEventFilesRetrieved), name: .NOTIFICATION_EVENT_LATEST_FILES_RETRIEVED, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(getlatestEventFilesFailed), name: .NOTIFICATION_EVENT_FAILED_TO_GET_LATEST_FILES, object: nil)
    }
    
    func setupSlider() {
        menuButton.target = revealViewController()
        menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
        
        revealViewController().rightViewRevealWidth = 150
        view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
    }
    
    func setupTableView() {
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        self.tableView.tableFooterView = UIView()
        self.tableView.estimatedRowHeight = 545
        let nib = UINib(nibName: XIBIdentifiers.XIB_HOME_CELL_IDENTIFIER, bundle:nil)
        self.tableView.register(nib, forCellReuseIdentifier: homeCellReuseIdentifier)

        // Configure Refresh Control
        let attributes = [NSAttributedStringKey.foregroundColor : EAUIColours.REFRESH_CONTROL_TINT_COLOUR]
        refreshControl.addTarget(self, action: #selector(refreshFilesList(_:)), for: .valueChanged)
        refreshControl.tintColor = UIColor.white
        refreshControl.attributedTitle = NSAttributedString(string: EAUIText.EAHOME_TABLE_VIEW_REFRESH_CONTROL_TITLE, attributes: attributes)
        // Add Refresh Control to Table View
        tableView.refreshControl = refreshControl
    }
    
    
    @IBAction func homeActionButtonClicked(_ sender: Any) {
        revealViewController().revealToggle(animated: true)
    }
    
    func share(_ shareImage:UIImage, shareText text:String?, source:UIView){
        var objectsToShare = [Any]()
        if let text = text{
            objectsToShare.append(text)
        }
        objectsToShare.append(shareImage)
        let activityViewController = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = source
        self.present(activityViewController, animated: true, completion:nil);
    }
    
    func didSwitchEvent(_ event:EAEvent?) {
        EAEvent.didSwitchEvent(event)
        resetHomeViewController()
    }
    
    @objc private func refreshFilesList(_ sender: Any) {
        //refresh the files
        EAGoogleAPIManager.sharedInstance.getLatestFilesForEvent(EAEvent.getCurrentEvent())
    }
    
    @IBAction func unWindToHomeViewController(_ sender: UIStoryboardSegue) {
        print("unWindToHomeViewController")
        self.tabBarController?.tabBar.isHidden = false;
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateNavigationBarTitle()
        hideShowTableView()
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func updateNavigationBarTitle() {
        let event = EAEvent.getCurrentEvent()
        if let currentEventName = event.name {
            self.navigationController?.navigationBar.topItem?.title = currentEventName
        }
    }
    
    func hideShowTableView() {
        let currentEventName:String = EAEvent.getCurrentEventName()
        var files:[Any] = [GTLDriveFile]()
        if let currentFilesList =  self.currentFilesList?.files {
            files = currentFilesList
        }
        if(currentEventName.isEmpty || files.isEmpty) {
            self.tableView.isHidden = true
        }
        else {
            self.tableView.reloadData()
            self.tableView.isHidden = false
        }
    }
    
    func addBackground(_ cell:EAHomeTableViewCell, file:GTLDriveFile!) -> UIImage? {
        let view:UIView = cell.placeHolderView
        // screen width and height:
        let width = view.bounds.size.width
        let height = view.bounds.size.height
        var bgImage:UIImage?
        var imageViewBackground:UIImageView?
        
        bgImage = EADeviceDataManager.sharedInstance.getImageFromFile(fileId: file.identifier!)
        if let bgImage = bgImage {
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
            if(!downlaodsInProgress.contains(file.identifier)) {
                downlaodsInProgress.append(file.identifier)
                EAGoogleAPIManager.sharedInstance.downloadFile(file)
            }
            if let view = view.viewWithTag(UIImageViewTagId) {
                imageViewBackground = view as? UIImageView
                imageViewBackground?.image = nil
            }
            self.activityIndicatorVisible(true, cell:cell)
        }
        return bgImage
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
        cell = tableView.dequeueReusableCell(withIdentifier: homeCellReuseIdentifier, for: indexPath) as? EAHomeTableViewCell
        let currentFilesList:NSArray? = self.currentFilesList!.files as NSArray?
        
        if let files = currentFilesList, let cell = cell {
            var file:GTLDriveFile?
            file = (files.object(at: indexPath.row) as! GTLDriveFile)
            if let file = file {
                setupTableViewCell(cell, forFile: file, andIndexPath: indexPath)
            }
        }
        
        return cell!
    }
    
    func setupTableViewCell(_ cell:EAHomeTableViewCell, forFile file:GTLDriveFile, andIndexPath indexPath:IndexPath) {
        cell.imageTitleLabel.text = file.name
        var bgImage:UIImage?
        if (self.currentFilesList?.files.indices.contains(indexPath.row) != nil) {
            bgImage = addBackground(cell, file: (self.currentFilesList?.files[indexPath.row] as! GTLDriveFile))
        }
        cell.shareAction = { [unowned self] in
            if let bgImage = bgImage {
                self.share(bgImage, shareText:EAUIText.SHARE_SINGLE_IMAGE_TEXT, source:cell.shareButton)
            }
        }
    }
    
    func activityIndicatorVisible(_ visible:Bool, cell:EAHomeTableViewCell!) {
        cell.activityIndicatorContainerView.isHidden = !visible
        
        if(visible) {
           cell.activityIndicator.startAnimating()
        }
    }
    
    open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return self.tableView.bounds.height
    }
    
    func addNewFilesToList(_ newfiles: inout [GTLDriveFile]) {
        var newFList = [GTLDriveFile]()
        newFList += newfiles
        if let files = self.currentFilesList?.files {
            newFList += (files as! [GTLDriveFile])
            self.currentFilesList?.files = newFList
        }
        self.tableView.reloadData()
    }
    
    // MARK:notifaction responses/selectors
    @objc func eventFileDownloaded(_ notifiaction : Notification) {
        print("event file downloaded")
        var fileId:String?
        if let fileData = notifiaction.object as? Data  {
            fileId = (notifiaction.userInfo!["fileId"] as! String)
            if let index = downlaodsInProgress.index(of: fileId!) {
                downlaodsInProgress.remove(at: index)
            }
            EADeviceDataManager.sharedInstance.writeFileToRootFolder(fileName:fileId!, data:fileData)
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
    
    @objc func newEventCreated(_ notifiaction : Notification) {
        print("new event folder created")
        revealViewController().revealToggle(animated: true)
        if let folder = notifiaction.object as? GTLDriveFile  {
            currentEventFolder = folder
            let defaults = UserDefaults.standard
            defaults.set(folder.name!, forKey: DEFAULT_CURRENT_EVENT_NAME)
            defaults.set(folder.identifier!, forKey: DEFAULT_CURRENT_EVENT_ID)
            updateNavigationBarTitle()
            let createdEvent:EAEvent = EAEvent(id: folder.identifier!,eventName: folder.name!)
            self.didSwitchEvent(createdEvent)
            resetHomeViewController()
        }
    }
    
    @objc func eventDeleted(_ notifiaction : Notification) {
        let defaults = UserDefaults.standard
        let currentEventId:String = defaults.string(forKey: DEFAULT_CURRENT_EVENT_ID)!
        if let event:EAEvent = notifiaction.object as? EAEvent, event.id == currentEventId {
            EAEvent.didSwitchEvent(nil);
            resetHomeViewController()
        }
    }
    
    @objc func getlatestEventFilesFailed(_ notifiaction : Notification) {
        refreshControl.endRefreshing()
        //TODO show alert to user
    }
    
    @objc func latestEventFilesRetrieved(_ notifiaction : Notification) {
        refreshControl.endRefreshing()
        let fileDetails:[String:Any] = notifiaction.userInfo as! [String:Any]
        let eventId:String = fileDetails[GoogleAPIKeys.EVENT_ID] as! String
        guard eventId == EAEvent.getCurrentEventId() else {
            print("files don't match current event selected.")
            return
        }
        if let fileList = notifiaction.object as? GTLDriveFileList  {
            //add any new files to the existing files list
            if let currentFilesList = self.currentFilesList  {
                    //we already have some files. Check if we don't have any of the 'latest'
                    var filesToAdd = [GTLDriveFile]()
                    for file in fileList.files {
                        var contains:Bool? = false
                        contains = currentFilesList.files!.contains(where: { (f:Any) -> Bool in
                                return (f as! GTLDriveFile).identifier == (file as! GTLDriveFile).identifier
                        })
                        if !contains! {
                            filesToAdd.append(file as! GTLDriveFile)
                        }
                    }
                    //call func to update tableview..
                    addNewFilesToList(&filesToAdd)
            }
            else {
                self.currentFilesList = fileList
            }
        }
        hideShowTableView()
    }
    
    @objc func eventFilesRetrieved(_ notifiaction : Notification) {
        print("event files retrieved selector")
        revealViewController().revealToggle(animated: true)
        if let fileList = notifiaction.object as? GTLDriveFileList  {
            currentFilesList = fileList
            self.tableView.reloadData()
        }
        hideShowTableView()
    }
    
    func resetHomeViewController() {
        self.currentFilesList = nil
        currentEventFolder = nil
        updateNavigationBarTitle()
        self.tableView.reloadData()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
 
}
