//
//  EAUploadProgressView.swift
//  EventsApp
//
//  Created by Keith Caffrey on 10/11/2017.
//  Copyright © 2017 KC. All rights reserved.
//

import Foundation
import UIKit

class EAUploadProgressView: UIView {
    
    
    @IBOutlet var contentView: EAUploadProgressView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        customInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        customInit()
    }
    
    func customInit() {
        Bundle.main.loadNibNamed("EAUploadProgressView", owner: self, options:nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight,.flexibleWidth]
    }
}
