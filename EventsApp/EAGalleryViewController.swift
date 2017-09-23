//
//  EAGalleryViewController.swift
//  EventsApp
//
//  Created by Keith Caffrey on 31/08/2016.
//  Copyright © 2016 KC. All rights reserved.
//

import Foundation
import ImagePicker

open class EAGalleryViewController: UIViewController, ImagePickerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var imagePickerPlaceholderView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    var imagePickerController:ImagePickerController?
    var data:[EAImageUpload]! = [EAImageUpload!]()
    let imageUplaodCellReuseIdentifier:String = "eaImageUploadTableViewCell"
    let UIImageViewTagId = 304
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        //setup table view
        //self.tableView = UITableView()
        //let screenSize:CGRect = UIScreen.main.bounds
        //tableView!.frame = CGRect(x:0, y:0, width:screenSize.width, height:screenSize.height)
        self.tableView!.dataSource = self
        self.tableView!.delegate = self
        self.tableView!.backgroundColor = UIColor.orange
        self.tableView!.rowHeight = UITableViewAutomaticDimension;
        self.tableView!.estimatedRowHeight = 545
        let nib = UINib(nibName: XIBIdentifiers.XIB_IMAGE_UPLOAD_CELL_IDENTIFIER, bundle:nil)
        self.tableView!.register(nib, forCellReuseIdentifier: imageUplaodCellReuseIdentifier)
        self.view.addSubview(self.tableView!)
        
        //setup image picker
        var configuration = Configuration()
        configuration.doneButtonTitle = "Upload"
        configuration.noImagesTitle = "Sorry! There are no images here!"
        configuration.recordLocation = false
        imagePickerController = ImagePickerController(configuration: configuration)
        imagePickerController!.delegate = self
        imagePickerController?.imageLimit = 4
        presentImagePicker()

    }
    
    override open func viewDidAppear(_ animated: Bool) {
      // presentImagePicker()
    }
    
   func presentImagePicker() {
        self.addChildViewController(imagePickerController!)
        self.view.addSubview(imagePickerController!.view)
    
        imagePickerController!.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(
            [imagePickerController!.view.leadingAnchor.constraint(equalTo: self.imagePickerPlaceholderView.leadingAnchor, constant: 0),
                imagePickerController!.view.trailingAnchor.constraint(equalTo: self.imagePickerPlaceholderView.trailingAnchor, constant:0),
                imagePickerController!.view.topAnchor.constraint(equalTo: self.imagePickerPlaceholderView!.topAnchor, constant: 0),
                imagePickerController!.view.bottomAnchor.constraint(equalTo: self.imagePickerPlaceholderView.bottomAnchor, constant: 0)
            ])
        imagePickerController!.didMove(toParentViewController: self)
      //present(imagePickerController!, animated: true, completion: nil)
    }
    
// MARK: - ImagePickerDelegate Methods
    
    open func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        
    }
    
    open func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
//        let defaults = UserDefaults.standard
//        let image:UIImage? = images[0]
//        let eventId:String? = defaults.string(forKey: DEFAULT_CURRENT_EVENT_ID)
//        let eventName:String? = defaults.string(forKey: DEFAULT_CURRENT_EVENT_NAME)
//        if let eventId = eventId, let eventName = eventName, let image = image {
//            let event:EAEvent = EAEvent(id:eventId , eventName: eventName)
//            EAGoogleAPIManager.sharedInstance.uploadImageToEvent(image,event:event)
//        }
        
        for image in images {
            let imageUpload:EAImageUpload = EAImageUpload(image: image, uploadPercentage: 0)
            data.append(imageUpload)
        }
        imagePickerController!.willMove(toParentViewController: nil)
        imagePickerController!.view.removeFromSuperview()
        imagePickerController!.removeFromParentViewController()
        self.tableView?.reloadData()
    }
    
    open func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        //return to the home vc
        self.performSegue(withIdentifier: SegueIdentifiers.EXIT_GALLERY_SEGUE,sender:self)
    }
    
// MARK: - UITableViewDelegate Methods
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count;
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell:EAImageUploadTableViewCell?
        if (self.data == nil || self.data.count < 1){
            return EAImageUploadTableViewCell()
        }
        var imageUpload:EAImageUpload?
        imageUpload = data![indexPath.row]
        
        cell = tableView.dequeueReusableCell(withIdentifier: imageUplaodCellReuseIdentifier, for: indexPath) as? EAImageUploadTableViewCell
        cell!.progressView.progress = imageUpload!.uploadPercentage
        //cell!.uploadImage.image = imageUpload!.image
        self.addBackground(cell!, imageUpload!.image!)
        return cell!
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
    
    
    open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
//        let topNavHeight:CGFloat = self.navigationController!.navigationBar.frame.height
//        let bottomNavHeight:CGFloat =  self.tabBarController!.tabBar.frame.height
//        let statusBarHeight:CGFloat = UIApplication.shared.statusBarFrame.size.height
        //let navHeight:CGFloat = topNavHeight+bottomNavHeight+statusBarHeight
        return self.tableView!.frame.height;
    }
    

}
