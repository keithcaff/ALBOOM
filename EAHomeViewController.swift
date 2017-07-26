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
    let homeCellIdentifier:String = "HOME_CELL_IDENTFIER"

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
        let nib = UINib(nibName: "EAHomeTableViewCell", bundle:nil)
        self.tableView.register(nib, forCellReuseIdentifier: homeCellIdentifier)
        
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
    
    
    func didSwitchEvent(_ event:EAEvent?) {
        self.currentFilesList = nil
        currentEventFolder = nil
        self.fileDataMap = Dictionary<String, Data>()
        var name:String = ""
        var id:String = ""
        let defaults = UserDefaults.standard
        
        if let event = event {
            name = event.name!
            id = event.id!
        }
        
        defaults.set(id, forKey: DEFAULT_CURRENT_EVENT_ID)
        defaults.set(name, forKey: DEFAULT_CURRENT_EVENT_NAME)
        updateNavBarTitle(name)
        
        self.tableView.reloadData()
    }
    
    func addBackground(_ view:UIView, file:GTLDriveFile!) {
        
        // screen width and height:
        let width = view.bounds.size.width
        let height = view.bounds.size.height
        var bgImage:UIImage?
        
        if let file = file {
            //TODO: use the actual file identifier here
            print("\(file.identifier)")
            let fileData:Data? = self.fileDataMap[file.identifier]
            
            if let fileData = fileData {
                bgImage = UIImage(data: fileData)
                let imageViewBackground = UIImageView(frame: CGRect(x: 0, y: 0, width: width, height: height))
                imageViewBackground.image = bgImage
                // you can change the content mode:
                imageViewBackground.contentMode = UIViewContentMode.scaleToFill
                imageViewBackground.translatesAutoresizingMaskIntoConstraints = false;
                view.addSubview(imageViewBackground)
                
                let top = NSLayoutConstraint(item: imageViewBackground, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem:view , attribute: NSLayoutAttribute.top, multiplier: 1, constant: 0)
                let bottom = NSLayoutConstraint(item: imageViewBackground, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem:view , attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 0)
                let leading = NSLayoutConstraint(item: imageViewBackground, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem:view , attribute: NSLayoutAttribute.leading, multiplier: 1, constant: 0)
                let trailing = NSLayoutConstraint(item: imageViewBackground, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem:view , attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: 0)
                
                view.addConstraint(top)
                view.addConstraint(bottom)
                view.addConstraint(leading)
                view.addConstraint(trailing)
                view.sendSubview(toBack: imageViewBackground)

            }
            else {
                self.showActivityIndicatory(view)
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
    
    open func tableView(_ tableView: UITableView,willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let homeCell:EAHomeTableViewCell = (cell as! EAHomeTableViewCell)
        //FYI:Adding background image here because the placeHolderview.frame.bounds seem to be incorrect on first call to cell for row
        for view in homeCell.placeHolderView.subviews{
            view.removeFromSuperview()
        }
        if (self.currentFilesList?.files.indices.contains(indexPath.row) != nil) {
            addBackground(homeCell.placeHolderView, file: (self.currentFilesList?.files[indexPath.row] as! GTLDriveFile))
        }
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
        
        cell = tableView.dequeueReusableCell(withIdentifier: homeCellIdentifier, for: indexPath) as? EAHomeTableViewCell
        cell?.imageTitleLabel.text = file?.name
        
        //        if let name:String = file?.name {
        //            cell?.imageTitleLabel.text = name
        //        }
        //        let bgImage:UIImage! = UIImage(named: "jake.jpg")
        //        bgImage.resizableImageWithCapInsets(UIEdgeInsetsMake(0,5,40,1), resizingMode: UIImageResizingMode.Stretch)
        //        let imageView:UIImageView = UIImageView(image: bgImage)
        //        cell?.backgroundView = imageView
        
        return cell!
    }
    
    
    
    
    func showActivityIndicatory(_ uiView: UIView) {
        let container: UIView = UIView()
        container.frame = uiView.frame
        container.center = uiView.center
        container.backgroundColor = UIColor(white: 0xffffff, alpha: 0.3)
        let loadingView: UIView = UIView()
        loadingView.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        loadingView.center = uiView.center
        loadingView.backgroundColor = UIColor(white: 0x444444, alpha: 0.7)
        loadingView.clipsToBounds = true
        loadingView.layer.cornerRadius = 10
        
        let actInd: UIActivityIndicatorView = UIActivityIndicatorView()
        actInd.frame = CGRect(x: 0.0, y: 0.0, width: 80.0, height: 80.0);
        actInd.activityIndicatorViewStyle =
            UIActivityIndicatorViewStyle.whiteLarge
        actInd.center = CGPoint(x: loadingView.frame.size.width / 2,
                                    y: loadingView.frame.size.height / 2);
        loadingView.addSubview(actInd)
        container.addSubview(loadingView)
        uiView.addSubview(container)
        actInd.startAnimating()
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
       didSwitchEvent(nil)
    }
    
    func updateNavBarTitle(_ title:String) {
        self.navigationController?.navigationBar.topItem?.title = title
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
}
