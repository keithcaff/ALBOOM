//
//  EAImageUploadTableViewCell.swift
//  EventsApp
//
//  Created by Keith Caffrey on 23/09/2017.
//  Copyright © 2017 KC. All rights reserved.
//

import Foundation

open class EAImageUploadTableViewCell:UITableViewCell {
    
    var cancelButtonClosure: (() -> Void)?
    @IBOutlet weak var imagePlaceHolderView: UIView!
    @IBOutlet weak var uploadProgressView: EAUploadProgressView!
    
    @IBAction func cancelButtonClicked(_ sender: Any) {
        if let cancelButtonClosure = cancelButtonClosure {
            cancelButtonClosure()
        }
    }
}

