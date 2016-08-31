//
//  EAGalleryViewController.swift
//  EventsApp
//
//  Created by Keith Caffrey on 31/08/2016.
//  Copyright © 2016 KC. All rights reserved.
//

import Foundation

public class EAGalleryViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    
    let imagePicker = UIImagePickerController()
    
    @IBOutlet weak var imagePickerViewArea: UIView!

    override public func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .PhotoLibrary

            imagePicker.view.translatesAutoresizingMaskIntoConstraints = false;
            view.addSubview(imagePicker.view)
//            
            let top = NSLayoutConstraint(item: imagePicker.view, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem:imagePickerViewArea , attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0)
            let bottom = NSLayoutConstraint(item: imagePicker.view, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem:imagePickerViewArea , attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0)
            let leading = NSLayoutConstraint(item: imagePicker.view, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem:imagePickerViewArea , attribute: NSLayoutAttribute.Leading, multiplier: 1, constant: 0)
            let trailing = NSLayoutConstraint(item: imagePicker.view, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem:imagePickerViewArea , attribute: NSLayoutAttribute.Trailing, multiplier: 1, constant: 0)
            
            view.addConstraint(top)
            view.addConstraint(bottom)
            view.addConstraint(leading)
            view.addConstraint(trailing)
            
        
        
    }
    
    override public func viewDidAppear(animated: Bool) {
        imageView.image = nil
        //presentImagePicker()
    }
    
    func presentImagePicker() {
        presentViewController(imagePicker, animated: false, completion: nil)
    }
    
    // MARK: - UIImagePickerControllerDelegate Methods
    public func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.contentMode = .ScaleAspectFit
            imageView.image = pickedImage
        }
        //dismissViewControllerAnimated(true, completion: nil)
    }
    
    public func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        //dismissViewControllerAnimated(true, completion: nil)
        //imagePicker.dismissViewControllerAnimated(true, completion:nil)
    }
}