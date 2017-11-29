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
    var uploadPercentage:Float?
    var name:String?
    
    init(image:UIImage!, uploadPercentage:Float!) {
        self.image = image
        self.uploadPercentage = uploadPercentage
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        var uuid = UUID().uuidString
        uuid = String(uuid.prefix(6))
        self.name = "\(dateFormatter.string(from:Date()))_\(uuid)_\(APP_NAME).\(DeviceFolderNames.EA_IMAGE_FILE_TYPE)"
    }
}
