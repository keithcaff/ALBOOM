
//
//  EAViewEventTableViewCell.swift
//  EventsApp
//
//  Created by Keith Caffrey on 24/07/2016.
//  Copyright © 2016 KC. All rights reserved.
//

import UIKit
import Foundation

class EAViewEventTableViewCell: UITableViewCell {
    
    @IBOutlet weak var name: UILabel!
    
    
    var unWindCallback: ((EAEvent) -> Void)?
    var event: EAEvent!
    @IBAction func didClickSelectButton(sender: AnyObject) {
        unWindCallback?(self.event)
    }
}
