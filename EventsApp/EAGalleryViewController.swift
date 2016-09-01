//
//  EAGalleryViewController.swift
//  EventsApp
//
//  Created by Keith Caffrey on 31/08/2016.
//  Copyright © 2016 KC. All rights reserved.
//

import Foundation
import ImagePicker

public class EAGalleryViewController: UIViewController, ImagePickerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    let imagePickerController = ImagePickerController()
    
    @IBOutlet weak var uploadButton: UIButton!
    @IBOutlet weak var selectButton: UIButton!
    
    @IBAction func selectButtonClicked(sender: AnyObject) {
        presentImagePicker()
    }
    override public func viewDidLoad() {
        super.viewDidLoad()
        uploadButton.enabled = false
        uploadButton.alpha = 0.3
        imagePickerController
        imagePickerController.delegate = self
        imagePickerController.imageLimit = 1
        Configuration.doneButtonTitle = "Done"
        Configuration.noImagesTitle = "Sorry! There are no images here!"
        presentViewController(imagePickerController, animated: true, completion: nil)
    }
    
    override public func viewDidAppear(animated: Bool) {
        imageView.image = nil
        presentImagePicker()
    }
    
   func presentImagePicker() {
        presentViewController(imagePickerController, animated: true, completion: nil)
    }
    
// MARK: - ImagePickerDelegate Methods
    
    public func wrapperDidPress(imagePicker: ImagePickerController, images: [UIImage]) {
        
    }
    public func doneButtonDidPress(imagePicker: ImagePickerController, images: [UIImage]) {
        imagePicker.dismissViewControllerAnimated(true, completion:nil)
        imageView.image = images[0]
    }
    public func cancelButtonDidPress(imagePicker: ImagePickerController) {
        
    }
}