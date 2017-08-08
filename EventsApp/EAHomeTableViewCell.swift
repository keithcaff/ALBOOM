//
//  EAHomeTableViewCell.swift
//  EventsApp
//
//  Created by Keith Caffrey on 03/08/2016.
//  Copyright © 2016 KC. All rights reserved.
//

import Foundation

open class EAHomeTableViewCell:UITableViewCell {
    
    @IBOutlet weak var imageTitleLabel: UILabel!
    @IBOutlet weak var placeHolderView: UIView!
    
    @IBOutlet weak var activityIndicatorContainerView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
}
