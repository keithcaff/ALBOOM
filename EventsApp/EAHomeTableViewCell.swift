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
    var retryDownloadAction:(() -> Void)?
    
    func setRetryDownloadOptionVisible(_ visible:Bool) {
        self.retryDownloadContainer.isHidden = !visible
    }
    
    @IBOutlet weak var retryDownloadButton: UIButton!
    @IBOutlet weak var retryDownloadContainer: UIView!
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
    
    @IBAction func retryDownloadButtonClicked(_ sender: Any) {
        if let retryDownloadAction = retryDownloadAction {
            retryDownloadAction()
        }
    }
    
    
}
