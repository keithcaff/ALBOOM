//
//  EAUploadImage.swift
//  EventsApp
//
//  Created by Keith Caffrey on 23/09/2017.
//  Copyright © 2017 KC. All rights reserved.
//

import Foundation


class EAImageUpload {
    var image:UIImage?
    var uploadPercentage:Float = 0
    var name:String?
    
    init(image:UIImage!, uploadPercentage:Float!) {
        self.image = image
        self.uploadPercentage = uploadPercentage
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .medium
        self.name = "\(dateFormatter.string(from:Date()))_\(APP_NAME).jpg"
    }
}
