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
        if let buttonClicked = sender as? UIButton {
            if let deleteAction = deleteAction, buttonClicked == deleteButton  {
                deleteAction()
            }
            if let shareAction = shareAction, buttonClicked == shareButton  {
                shareAction()
            }
        }
        self.dismiss(animated: true, completion: nil)
    }
}
