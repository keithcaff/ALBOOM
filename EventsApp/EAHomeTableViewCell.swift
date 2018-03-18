//
//  EAHomeTableViewCell.swift
//  EventsApp
//
//  Created by Keith Caffrey on 03/08/2016.
//  Copyright © 2016 KC. All rights reserved.
//

import Foundation

open class EAHomeTableViewCell:UITableViewCell {
    
    
    @IBOutlet weak var optionsButton: UIButton!
    @IBOutlet weak var tagButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    var optionsAction:(() -> Void)?
    var shareAction:(() -> Void)?
    var tagAction:(() -> Void)?
    
    @IBOutlet weak var imageTitleLabel: UILabel!
    @IBOutlet weak var placeHolderView: UIView!
    @IBOutlet weak var activityIndicatorContainerView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!    
    @IBAction func shareButtonClicked(_ sender: Any) {
        if let shareAction = self.shareAction {
            shareAction()
        }
    }
    
    @IBAction func tagButtonClicked(_ sender: Any) {
        if let tagAction = self.tagAction {
            tagAction()
        }
    }
    
    
    @IBAction func optionsButtonClicked(_ sender: Any) {
        if let optionsAction = self.optionsAction {
            optionsAction()
        }
    }
    
}
