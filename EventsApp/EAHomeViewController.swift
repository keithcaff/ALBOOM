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
import Lightbox

open class EAHomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, EAEventUpdateDelegate, UIPopoverPresentationControllerDelegate {
    
    
    public func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }

    @IBOutlet weak var tableViewContainer: UIStackView!
    @IBOutlet weak var searchBarController: UISearchBar!
    @IBOutlet weak var homeActionButton: UIButton!
    @IBOutlet var tableView: UITableView!
    private var currentEventFolder:GTLDriveFile?
    private var currentFilesList:GTLDriveFileList!
    private var downlaodsInProgress:[String] = [String]()
    private var deletesInProgress:[String] = [String]()
    private var failedFileDownloads:[String] = [String]()
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
        setupSearchController()
    }
    
    func setupNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(newEventCreated), name: .NOTIFICATION_EVENT_FOLDER_CREATED, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(eventFileDownloaded), name: .NOTIFICATION_EVENT_FILE_DOWNLOADED, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(fileDownloadFailed), name: .NOTIFICATION_EVENT_FILE_DOWNLOAD_FAILED, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(eventDeleted), name: .NOTIFICATION_EVENT_FOLDER_DELETED, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(eventFilesRetrieved), name: .NOTIFICATION_EVENT_FILES_RETRIEVED, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(latestEventFilesRetrieved), name: .NOTIFICATION_EVENT_LATEST_FILES_RETRIEVED, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(getlatestEventFilesFailed), name: .NOTIFICATION_EVENT_FAILED_TO_GET_LATEST_FILES, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(fileDeleted), name: .NOTIFICATION_EVENT_FILE_DELETED, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(fileDeleteFailed), name: .NOTIFICATION_EVENT_FILE_DELETE_FAILED, object: nil)
    }
    
    func setupSlider() {
        menuButton.target = revealViewController()
        menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
        
        revealViewController().rightViewRevealWidth = 150
        view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
    }
    
    func setupSearchController() {
        //self.searchBarController.
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
        refreshControl.backgroundColor = EAUIColours.PRIMARY_BLUE
    }
    
    func getDeletFailedAlert() -> UIAlertController {
        let alert = UIAlertController(title: EAUIText.ALERT_DELETE_FILE_FAILED_TITLE, message: EAUIText.ALERT_DELETE_FILE_FAILED_MESSAGE, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler:nil))
        return alert
    }
    
    func scrollToTop() {
        self.tableView?.setContentOffset(CGPoint.zero, animated: true)
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
        self.navigationController?.navigationBar.topItem?.title = event.displayName
    }
    
    func hideShowTableView() {
        let currentEventName:String = EAEvent.getCurrentEventName()
        var files:[Any] = [GTLDriveFile]()
        if let currentFilesList =  self.currentFilesList?.files {
            files = currentFilesList
        }
        if(currentEventName.isEmpty || files.isEmpty) {
            self.tableViewContainer.isHidden = true
            //self.searchBarController.isHidden = true //TODO:add back in when allowing tag functionality
        }
        else {
            self.tableView.reloadData()
            self.tableViewContainer.isHidden = false
            //self.searchBarController.isHidden = (files.count < 2) //TODO:add back in when allowing tag functionality
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
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let file = getFileForIndexPath(indexPath) {
            displayPreviewForFile(file)
            //todo:remove this test code
            EAGoogleAPIManager.sharedInstance.updateFile(file)
            
        }
    }
    
    func displayPreviewForFile(_ file:GTLDriveFile) {
        if let bgImage = EADeviceDataManager.sharedInstance.getImageFromFile(fileId: file.identifier) {
            let images:[LightboxImage] = [LightboxImage(image:bgImage)]
            let previewController = LightboxController(images:images)
            previewController.dynamicBackground = true
            self.present(previewController, animated:true)
        }
    }
    
    func getFileForIndexPath(_ indexPath:IndexPath) -> GTLDriveFile? {
        var file:GTLDriveFile?
        let currentFilesList:NSArray = self.currentFilesList.files as NSArray
        file = currentFilesList.object(at: indexPath.row) as? GTLDriveFile
        return file
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell:EAHomeTableViewCell
        
        if (self.currentFilesList?.files == nil || self.currentFilesList!.files.count < 1){
            return EAHomeTableViewCell()
        }
        
        cell = tableView.dequeueReusableCell(withIdentifier: homeCellReuseIdentifier, for: indexPath) as! EAHomeTableViewCell
        
        let currentFilesList:NSArray = self.currentFilesList.files as NSArray
        if let file = currentFilesList.object(at: indexPath.row) as? GTLDriveFile {
            setupTableViewCell(cell, forFile: file, andIndexPath: indexPath)
        }
        
        return cell
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
        setActivityIndicatorForFile(file, andCell: cell)
        cell.tagButton.isHidden = true //TODO:tag functionality
        cell.optionsAction = getOptionsActionForCell(cell, andFile: file)
        cell.tagAction = getTagActionForFile(file)
    }
    
    private func getOptionsActionForCell(_ cell:EAHomeTableViewCell, andFile file:GTLDriveFile) -> ()->Void {
        let action:(()->Void) = { [weak self] in
            let popoverContent = EAHomeTableViewCellPopover()
            popoverContent.modalPresentationStyle = .popover
            popoverContent.deleteAction = { [weak self] in
                self?.activityIndicatorVisible(true, cell:cell)
                let deleteInProgress = self?.deletesInProgress.contains(file.identifier)
                if let inProgress = deleteInProgress, !inProgress {
                    self?.deletesInProgress.append(file.identifier)
                    EAGoogleAPIManager.sharedInstance.deleteFile(file, fromEvent: EAEvent.getCurrentEvent())
                }
            }
            
            popoverContent.shareAction = {
                if let shareAction = cell.shareAction {
                    shareAction()
                }
            }
            if let popover = popoverContent.popoverPresentationController {

                let viewForSource = cell.optionsButton
                popover.sourceView = viewForSource

                // the position of the popover where it's showed
                popover.sourceRect = cell.optionsButton.bounds

                // the size you want to display
                popoverContent.preferredContentSize = CGSize(width: 140, height: popoverContent.view.frame.height)
                popover.delegate = self
            }
            self?.present(popoverContent, animated: true, completion: nil)

        }
        return action
    }
    
    private func getTagActionForFile(_ file:GTLDriveFile) -> (()->Void) {
        let action:(()->Void) = { [unowned self] in
            
            if EADeviceDataManager.sharedInstance.getImageFromFile(fileId: file.identifier) != nil {
                let alertController = UIAlertController(title: "Tag the photo!", message: "Add a tag", preferredStyle: .alert)
                
                alertController.addTextField(configurationHandler: { (textField) -> Void in
                    textField.placeholder = "Tag1"
                    textField.textAlignment = .center
                })
                alertController.addTextField(configurationHandler: { (textField) -> Void in
                    textField.placeholder = "Tag2"
                    textField.textAlignment = .center
                })
                
                
                let okAction:UIAlertAction = UIAlertAction(title: "Ok", style: .default) { (action) in
                    print("OK button Pressed")
                }
                alertController.addAction(okAction)
                
                //public convenience init(title: String?, style: UIAlertActionStyle, handler: ((UIAlertAction) -> Swift.Void)? = nil)
                    alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:nil))
                
                self.present(alertController, animated: true, completion: nil)
            }
        }
        return action
    }
    
    func tagImageHandler(alert: UIAlertAction!)
    {
        print("ok button handler!")
    }
    
    func activityIndicatorVisible(_ visible:Bool, cell:EAHomeTableViewCell!) {
        cell.activityIndicatorContainerView.isHidden = !visible
        if (visible) {
            if let view = cell.placeHolderView.viewWithTag(self.UIImageViewTagId) {
                cell.placeHolderView.sendSubview(toBack: view)
            }
           cell.activityIndicator.startAnimating()
        }
    }
    
    open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        let searchBarHeight:CGFloat = self.tableView.tableHeaderView?.frame.height ?? 0
        return self.tableView.bounds.height - searchBarHeight
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
        if let fileData = notifiaction.object as? Data, let fileId = notifiaction.userInfo!["fileId"] as? String  {
            if let index = downlaodsInProgress.index(of: fileId) {
                downlaodsInProgress.remove(at: index)
            }
            if let downloadsFailedIndex = failedFileDownloads.index(of: fileId) {
                failedFileDownloads.remove(at: downloadsFailedIndex)
            }
            EADeviceDataManager.sharedInstance.writeFileToRootFolder(fileName:fileId, data:fileData)
            reloadRowForFile(fileId)
        }
    }
    
    @objc func fileDownloadFailed(_ notifiaction : Notification) {
        print("event file download failed")
        if let file = notifiaction.object as? GTLDriveFile {
            if let index = downlaodsInProgress.index(of: file.identifier) {
                downlaodsInProgress.remove(at: index)
            }
            let faliedDownloadIdIndex = failedFileDownloads.index(of: file.identifier)
            if faliedDownloadIdIndex == nil {
                downlaodsInProgress.append(file.identifier)
            }
            reloadRowForFile(file.identifier)
        }
    }
    
    func reloadRowForFile(_ fileId:String) {
        var fileIndex:Int?
        if let currentFilesList = currentFilesList {
            for (index, element) in currentFilesList.files.enumerated() {
                if (element as! GTLDriveFile).identifier == fileId {
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
    
    @objc func fileDeleted(_ notifiaction : Notification) {
        DispatchQueue.main.async {
            if let file = notifiaction.object as? GTLDriveFile, let userInfo = notifiaction.userInfo as? [String:Any],
                let event:EAEvent = userInfo["event"] as? EAEvent {
                print("received file deleted successfully notification")
                if EAEvent.getCurrentEventId() == event.id {
                    var fileIndex:Int?
                    if let currentFilesList = self.currentFilesList, let files = currentFilesList.files, let driveFiles = files as? [GTLDriveFile] {
                        for (index, element) in driveFiles.enumerated() {
                            if element.identifier == file.identifier {
                                fileIndex = index
                            }
                        }
                        if let fileIndex = fileIndex {
                            if let deleteInProgressIndex = self.deletesInProgress.index(of: file.identifier) {
                                self.deletesInProgress.remove(at: deleteInProgressIndex)
                            }
                            var newFiles:[GTLDriveFile] = []
                            newFiles.append(contentsOf:driveFiles)
                            newFiles.remove(at: fileIndex)
                            self.currentFilesList.files = newFiles
                            let index:IndexPath = IndexPath(row:fileIndex, section:0)
                            self.tableView.deleteRows(at: [index], with: UITableViewRowAnimation.automatic)
                            self.hideShowTableView()
                            EADeviceDataManager.sharedInstance.deleteFile(fileId: file.identifier)
                        }
                    }
                }
            }
        }
    }
    
    func setActivityIndicatorForFile(_ file:GTLDriveFile, andCell cell:EAHomeTableViewCell) {
        let deleteInProgress = deletesInProgress.contains(file.identifier)
        let downloadFailed = failedFileDownloads.contains(file.identifier)
        let backgroundView:UIView? = view.viewWithTag(UIImageViewTagId)
        var hasBackgroundImage = false
        if let backgroundView = backgroundView as? UIImageView {
           hasBackgroundImage = backgroundView.image != nil
        }

        let displayActivityIndicator = !hasBackgroundImage || deleteInProgress
        activityIndicatorVisible(displayActivityIndicator, cell: cell)
    }
    
    @objc func fileDeleteFailed(_ notifiaction : Notification) {
        DispatchQueue.main.async {
            print("received file delete failed notification")
            if let file = notifiaction.object as? GTLDriveFile, let userInfo = notifiaction.userInfo as? [String:Any],
                let event:EAEvent = userInfo["event"] as? EAEvent {
                if EAEvent.getCurrentEventId() == event.id {
                    if let deleteInProgressIndex = self.deletesInProgress.index(of: file.identifier) {
                        self.deletesInProgress.remove(at: deleteInProgressIndex)
                        self.reloadRowForFile(file.identifier)
                        self.present(self.getDeletFailedAlert(), animated: false)
                    }
                }
            }
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
            if let currentFilesList = self.currentFilesList, let currentFiles = currentFilesList.files, currentFiles.count > 0 {
                //we already have some files. Check if we don't have any of the 'latest'
                var filesToAdd = [GTLDriveFile]()
                if let latestFiles = fileList.files, let latestDriveFiles = latestFiles as? [GTLDriveFile]  {
                    for file in latestDriveFiles {
                        var fileExistsAlready:Bool? = false
                        if let driveFiles = currentFilesList.files as? [GTLDriveFile] {
                            fileExistsAlready = driveFiles.contains { f in
                                let result = f.identifier == file.identifier
                                return result
                            }
                            if let fileExists = fileExistsAlready, !fileExists {
                                filesToAdd.append(file)
                            }
                        }
                    }
                    //call func to update tableview..
                    addNewFilesToList(&filesToAdd)
                }
            }
            else {
                self.currentFilesList = fileList
            }
        }
        hideShowTableView()
    }
    
    @objc func eventFilesRetrieved(_ notifiaction : Notification) {
        print("event files retrieved selector")
        DispatchQueue.main.async {
            self.revealViewController().revealToggle(animated: true)
            if let fileList = notifiaction.object as? GTLDriveFileList  {
                self.currentFilesList = fileList
                self.tableView.reloadData()
            }
            self.hideShowTableView()
        }
    }
    
    func resetHomeViewController() {
        self.currentFilesList = nil
        currentEventFolder = nil
        deletesInProgress = []
        downlaodsInProgress = []
        updateNavigationBarTitle()
        self.tableView.reloadData()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
 
}
