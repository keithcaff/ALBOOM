//
//  EAGalleryViewController.swift
//  EventsApp
//
//  Created by Keith Caffrey on 31/08/2016.
//  Copyright © 2016 KC. All rights reserved.
//

import Foundation
import ImagePicker

open class EAGalleryViewController: UIViewController, ImagePickerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    var imagePickerController:ImagePickerController?
    
    override open func viewDidLoad() {
        super.viewDidLoad()
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
       presentImagePicker()
    }
    
   func presentImagePicker() {
        present(imagePickerController!, animated: true, completion: nil)
    }
    
// MARK: - ImagePickerDelegate Methods
    
    open func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        
    }
    
    open func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        let defaults = UserDefaults.standard
        let image:UIImage? = images[0]
        let eventId:String? = defaults.string(forKey: DEFAULT_CURRENT_EVENT_ID)
        let eventName:String? = defaults.string(forKey: DEFAULT_CURRENT_EVENT_NAME)
        if let eventId = eventId, let eventName = eventName, let image = image {
            let event:EAEvent = EAEvent(id:eventId , eventName: eventName)
            EAGoogleAPIManager.sharedInstance.uploadImageToEvent(image,event:event)
        }
    }
    open func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        //return to the home vc
        self.performSegue(withIdentifier: SegueIdentifiers.EXIT_GALLERY_SEGUE,sender:self)
    }

}
