//
//  EAViewEventTableViewCell.swift
//  EventsApp
//
//  Created by Keith Caffrey on 24/07/2016.
//  Copyright © 2016 KC. All rights reserved.
//

import Foundation

class EAViewEventTableViewCell: UITableViewCell {
    
    @IBOutlet weak var name: UILabel!
    
    @IBAction func didClickSelectButton(sender: AnyObject) {
        print("didClickSelectButton")
        //fire off call to google api to retrieve event folders
        //trigger unwind using a cllback block for the cell
        //https://medium.com/cobe-mobile/why-you-shouldn-t-use-delegates-in-swift-7ef808a7f16b#.18gwofcbb
    }
}
