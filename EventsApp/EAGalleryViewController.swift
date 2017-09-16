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
    
    
    
    @IBOutlet weak var imagePickerPlaceHolderView: UIView!
    override open func viewDidLoad() {
        super.viewDidLoad()
        imagePickerController.delegate = self
        //imagePickerController.imageLimit = 1
//        Configuration.doneButtonTitle = "Done"
//        Configuration.noImagesTitle = "Sorry! There are no images here!"
        //present(imagePickerController, animated: true, completion: nil)
        presentImagePicker()
    }
    
    override open func viewDidAppear(_ animated: Bool) {
       presentImagePicker()
    }
    
   func presentImagePicker() {
//        self.addChildViewController(imagePickerController)
//        self.imagePickerPlaceHolderView.addSubview(imagePickerController.view)
//    
//        imagePickerController.view.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//        imagePickerController.view.leadingAnchor.constraint(equalTo: imagePickerPlaceHolderView.leadingAnchor, constant: 0),
//        imagePickerController.view.trailingAnchor.constraint(equalTo: imagePickerPlaceHolderView.trailingAnchor, constant: 0),
//        imagePickerController.view.topAnchor.constraint(equalTo: imagePickerPlaceHolderView.topAnchor, constant: 0),
//        imagePickerController.view.bottomAnchor.constraint(equalTo: imagePickerPlaceHolderView.bottomAnchor, constant: 0)
//        ])
//    
//        imagePickerController.didMove(toParentViewController: self)
    
        present(imagePickerController, animated: true, completion: nil)
    }
    
// MARK: - ImagePickerDelegate Methods
    
    open func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        
    }
    open func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        //transition to an upload screen
    }
    open func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        //return to the home vc
        self.performSegue(withIdentifier: SegueIdentifiers.EXIT_GALLERY_SEGUE,sender:self)
    }

}
