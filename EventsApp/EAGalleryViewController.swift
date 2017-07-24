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
    let imagePickerController = ImagePickerController()
    
    @IBOutlet weak var uploadButton: UIButton!
    @IBOutlet weak var selectButton: UIButton!
    
    @IBAction func selectButtonClicked(_ sender: AnyObject) {
        presentImagePicker()
    }
    override open func viewDidLoad() {
        super.viewDidLoad()
        uploadButton.isEnabled = false
        uploadButton.alpha = 0.3
        imagePickerController
        imagePickerController.delegate = self
        imagePickerController.imageLimit = 1
//        Configuration.doneButtonTitle = "Done"
//        Configuration.noImagesTitle = "Sorry! There are no images here!"
        present(imagePickerController, animated: true, completion: nil)
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        imageView.image = nil
        presentImagePicker()
    }
    
   func presentImagePicker() {
        present(imagePickerController, animated: true, completion: nil)
    }
    
// MARK: - ImagePickerDelegate Methods
    
    open func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        
    }
    open func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        imagePicker.dismiss(animated: true, completion:nil)
        imageView.image = images[0]
    }
    open func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        
    }
}
