//
//  EAGalleryViewController.swift
//  EventsApp
//
//  Created by Keith Caffrey on 31/08/2016.
//  Copyright © 2016 KC. All rights reserved.
//

import Foundation
import Gallery
open class EAGalleryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, GalleryControllerDelegate {

    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var imagePickerPlaceholderView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    var uploadSuccessAlert:UIAlertController!
    var gallery: GalleryController?
    var data:[EAImageUpload] = [EAImageUpload]()
    var failedUploads:[EAImageUpload] = [EAImageUpload]()
    let imageUplaodCellReuseIdentifier:String = "eaImageUploadTableViewCell"
    let UIImageViewTagId = 304
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        self.setupNotifications()
        self.setupTableView()
        self.configureGallery()
        setupAlerts()
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if (self.data.count == 0) {
            presentImagePickerWithAlert(nil)
        }
    }
    
    func configureGallery() {
        Gallery.Config.tabsToShow = [.imageTab, .cameraTab]
        Gallery.Config.Camera.imageLimit = 5
    }
    
    func setupAlerts() {
        uploadSuccessAlert = UIAlertController(title: "Upload complete", message: "Image(s) uploaded to Google Drive", preferredStyle: UIAlertControllerStyle.alert)
        uploadSuccessAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler:nil))
    }
    
    func setupNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(uploadProgressUpated), name: .NOTIFICATION_IMAGE_UPLOAD_PROGRESS_UPDATE, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(imageUploadedSuccessfully), name: .NOTIFICATION_IMAGE_UPLOADED, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(imageUploadFailed), name: .NOTIFICATION_IMAGE_UPLOAD_FAILED, object: nil)
    }
    
    func setupTableView() {
        tableView!.dataSource = self
        tableView!.delegate = self
        tableView!.isHidden = true
        tableView!.rowHeight = UITableViewAutomaticDimension;
        tableView!.estimatedRowHeight = 545
        let nib = UINib(nibName: XIBIdentifiers.XIB_IMAGE_UPLOAD_CELL_IDENTIFIER, bundle:nil)
        tableView!.register(nib, forCellReuseIdentifier: imageUplaodCellReuseIdentifier)
        view.addSubview(self.tableView!)
    }
    
    func presentImagePickerWithAlert(_ alert:UIAlertController?) {
        gallery = GalleryController()
        gallery!.delegate = self
        if alert != nil {
            present(gallery!, animated: true, completion: {
                self.gallery!.present(alert!, animated:true, completion:nil)
            })
        }
        else {
            present(gallery!, animated: true, completion: nil)
        }
    }
    
    func getRetryClosure(_ event:EAEvent, _ image:EAImageUpload) -> () -> Void {
        let retry: () -> Void = { [weak self] in
            EAGoogleAPIManager.sharedInstance.uploadImageToEvent(image,event:event)
            if let i = self?.failedUploads.index(where: { $0.name == image.name!  }) {
                self?.failedUploads.remove(at: i)
                let indexPath = IndexPath(row: i, section: 0)
                self?.tableView.reloadRows(at: [indexPath], with: .none)
            }
        }
        return retry
    }
    
    func didUploadFail (imageUpload:EAImageUpload) -> Bool {
        let contains = failedUploads.contains(where: { (f:Any) -> Bool in
            return (f as! EAImageUpload).name == imageUpload.name!
        })
        return contains
    }
    // MARK: - IBActions
    
    @IBAction func plusButtonClicked(_ sender: Any) {
        presentImagePickerWithAlert(nil)
    }
    
    // MARK: - UITableViewDelegate Methods
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count;
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell:EAImageUploadTableViewCell?
        if (self.data.count < 1) {
            return EAImageUploadTableViewCell()
        }
        var imageUpload:EAImageUpload?
        imageUpload = data[indexPath.row]
        
        cell = tableView.dequeueReusableCell(withIdentifier: imageUplaodCellReuseIdentifier, for: indexPath) as? EAImageUploadTableViewCell
        setupTableViewCell(cell: cell!, imageUpload: imageUpload!)
        return cell!
    }
    
    func setupTableViewCell(cell:EAImageUploadTableViewCell, imageUpload:EAImageUpload) {
        cell.uploadProgressView.buutonClickedClosure = getRetryClosure(EAEvent.getCurrentEvent(), imageUpload)
        addBackground(cell, imageUpload.image!)
        let displayRetryButton = didUploadFail(imageUpload: imageUpload)
        cell.uploadProgressView.progressContainerView.isHidden = displayRetryButton
        cell.uploadProgressView.retryContainerView.isHidden = !displayRetryButton
         //TODO: IF failedUploads contains this image then hide the progress bar and show a retry option. Set the buutonClickedClosure here!!!
        cell.uploadProgressView.progressView.progress = imageUpload.uploadPercentage!
    }
    
    func addBackground(_ cell:EAImageUploadTableViewCell, _ image:UIImage!) {
        let view:UIView = cell.imagePlaceHolderView
        // screen width and height:
        let width = view.bounds.size.width
        let height = view.bounds.size.height
        let bgImage:UIImage = image!
        var imageViewBackground:UIImageView?
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
    
    open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.tableView!.frame.height;
    }
    
    @objc func uploadProgressUpated(_ notifiaction : Notification) {
        let uploadDetails:[String:Any] = notifiaction.object as! [String:Any]
        let imageName:String =  uploadDetails[GoogleAPIKeys.IMAGE_NAME] as! String
        let uploadPercentage:Float =  uploadDetails[GoogleAPIKeys.UPLOAD_PERCENTAGE] as! Float
        print("uploadProgressUpated: \(imageName) image \(uploadPercentage)%")
        if let i = data.index(where: { $0.name == imageName  }) {
            let eaImageUpload:EAImageUpload = data[i]
            eaImageUpload.uploadPercentage = uploadPercentage
            let indexPath = IndexPath(row: i, section: 0)
            self.tableView.reloadRows(at: [indexPath], with: .none)
        }
    }
    
    @objc func imageUploadedSuccessfully(_ notifiaction : Notification) {
        print("imageUploadedSuccessfully CALLED!!!")
        let uploadDetails:[String:Any] = notifiaction.object as! [String:Any]
        let imageUpload:EAImageUpload =  uploadDetails[GoogleAPIKeys.IMAGE_UPLOAD] as! EAImageUpload
        if let i = data.index(where: { $0.name == imageUpload.name!  }) {
            if let indexOfFailedUpload = failedUploads.index(where: { $0.name == imageUpload.name!}) {
                failedUploads.remove(at: indexOfFailedUpload)
            }
            data.remove(at: i)
            let indexPath = IndexPath(row: i, section: 0)
            tableView.deleteRows(at: [indexPath], with: .fade)
            if (data.isEmpty) {
                presentImagePickerWithAlert(self.uploadSuccessAlert)
            }
        }
    }
    
    @objc func imageUploadFailed(_ notifiaction : Notification) {
        let uploadDetails:[String:Any] = notifiaction.object as! [String:Any]
        let imageUpload:EAImageUpload =  uploadDetails[GoogleAPIKeys.IMAGE_UPLOAD] as! EAImageUpload
        if let i = data.index(where: { $0.name == imageUpload.name! }) {
            let uploadFailed = didUploadFail(imageUpload:imageUpload)
            if !uploadFailed {
                data[i].uploadPercentage = 0.0
                failedUploads.append(data[i])
            }
            let indexPath = IndexPath(row: i, section: 0)
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
    
    func updateViewWithSelectedImages(_ images: [UIImage]) {
        let defaults = UserDefaults.standard
        let eventId:String? = defaults.string(forKey: DEFAULT_CURRENT_EVENT_ID)
        let eventName:String? = defaults.string(forKey: DEFAULT_CURRENT_EVENT_NAME)
        
        for image in images {
            if let eventId = eventId, let eventName = eventName {
                let event:EAEvent = EAEvent(id:eventId , eventName: eventName)
                let imageUpload:EAImageUpload = EAImageUpload(image: image, uploadPercentage: 0)
                data.append(imageUpload)
                EAGoogleAPIManager.sharedInstance.uploadImageToEvent(imageUpload,event:event)
            }
        }
        
        if(!data.isEmpty) {
            self.tableView!.isHidden = false
        }
        
        self.tableView?.reloadData()
    }
    
    // MARK: - GalleryControllerDelegate
    public func galleryController(_ controller: GalleryController, didSelectImages images: [Image]) {
        var imagesToProcess:[UIImage] = [UIImage]()
        for image in images {
            let size:CGSize = CGSize(width:image.asset.pixelWidth, height:image.asset.pixelHeight)
            imagesToProcess.append(image.uiImage(ofSize: size)!)
        }
        gallery!.dismiss(animated: true, completion: nil)
        updateViewWithSelectedImages(imagesToProcess)
    }
    
    public func galleryController(_ controller: GalleryController, didSelectVideo video: Video) {
        
    }
    
    public func galleryController(_ controller: GalleryController, requestLightbox images: [Image]) {
        
    }
    
    public func galleryControllerDidCancel(_ controller: GalleryController) {
        gallery!.dismiss(animated: true, completion: nil)
        self.performSegue(withIdentifier: SegueIdentifiers.EXIT_GALLERY_SEGUE,sender:self)
    }

}
