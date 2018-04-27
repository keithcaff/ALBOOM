//
//  EAHomeTableViewCellPopover.swift
//  ALBOOM
//
//  Created by Keith Caffrey on 26/04/2018.
//  Copyright © 2018 KC. All rights reserved.
//

import Foundation

class EAHomeTableViewCellPopover: UIViewController {

    @IBOutlet weak var buttonOne: UIButton!
    
    @IBOutlet weak var buttonTwo: UIButton!
    
    @IBOutlet weak var buttonThree: UIButton!
    //kctest
    
    
    override func viewDidLoad() {
        buttonOne.titleLabel?.text = "1"
        buttonTwo.titleLabel?.text = "2"
        buttonThree.titleLabel?.text = "3"
    }
    
    @IBAction func buttonClicked(_ sender: Any) {
        print("a button was clicked!")
    }
    
}
