//
//  EAHomeTableViewCellPopover.swift
//  ALBOOM
//
//  Created by Keith Caffrey on 26/04/2018.
//  Copyright © 2018 KC. All rights reserved.
//

import Foundation

class EAHomeTableViewCellPopover: UIViewController {
    
    @IBOutlet weak var shareButton: UIButton!
    
    @IBOutlet weak var buttonTwo: UIButton!
    
    @IBOutlet weak var deleteButton: UIButton!
    
    var deleteAction:(() -> Void)?
    var shareAction:(() -> Void)?
    
    
    override func viewDidLoad() {
        shareButton.isHidden = false
        buttonTwo.isHidden = true
        deleteButton.isHidden = false
    }
    
    @IBAction func buttonClicked(_ sender: Any) {
        var deleteOnDismiss = false
        if let buttonClicked = sender as? UIButton {
            deleteOnDismiss = buttonClicked == deleteButton
            if let shareAction = shareAction, buttonClicked == shareButton  {
                shareAction()
            }
        }
        self.dismiss(animated: true, completion: {
            //triggering delete action on dismiss because we can't present two allerts at the same time
            //i.e. are you sure you want to delete ...
            if let deleteAction = self.deleteAction, deleteOnDismiss {
                deleteAction()
            }
        })
    }
}
