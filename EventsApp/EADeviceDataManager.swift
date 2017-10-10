//
//  EADeviceDataManager.swift
//  EventsApp
//
//  Created by Keith Caffrey on 09/10/2017.
//  Copyright © 2017 KC. All rights reserved.
//

import Foundation


class EADeviceDataManager {
    open static let sharedInstance = EADeviceDataManager()
    fileprivate var rootFolder:String?
    fileprivate init() {
        
    }
    
    
    private func createRootFolder() {
        var paths: [Any] = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory: String = paths[0] as! String
        // Get documents folder
        let dataPath: String = "\(documentsDirectory)/\(DeviceFolderNames.EA_ROOT_DEVICE_FOLDER)"
        if !FileManager.default.fileExists(atPath: dataPath) {
            do {
                try FileManager.default.createDirectory(atPath: dataPath, withIntermediateDirectories: false, attributes: nil)
            }
            catch let error as NSError {
                print("Failed to create root folder. Reason: \(error.debugDescription)")
            }
        }
        self.rootFolder = dataPath
    }
    
    
    open func writeFileToRootFolder(fileName:String , data:Data ) {
        print("KCTEST writeFileToRootFolder")
        if (self.rootFolder == nil || !FileManager.default.fileExists(atPath: self.rootFolder!)) {
            createRootFolder()
        }
        
        if let rootFolder = rootFolder {
            //write file to the root folder
            let filePath = "\(rootFolder)/\(fileName)\(DeviceFolderNames.EA_IMAGE_FILE_TYPE)"
            let success = FileManager.default.createFile(atPath: filePath, contents: data, attributes:nil)
            
            if (!success) {
                NSLog("Unable to write file to directory. file:\(fileName)")
            }
        }
    }
    
    
    open func getImageFromFile(fileId:String) -> UIImage? {
        var image:UIImage?
        guard let root = rootFolder else {
            return image
        }
        let fileName:String = "\(fileId)\(DeviceFolderNames.EA_IMAGE_FILE_TYPE)"
        let filePath:String = "\(root)/\(fileName)\(DeviceFolderNames.EA_IMAGE_FILE_TYPE)"
        if (FileManager.default.fileExists(atPath: filePath)) {
            let url = URL(string: filePath)
            do {
                let imageData =  try Data(contentsOf: url!)
                image = UIImage(data: imageData)
            }
            catch let error as NSError {
                print("Failed to create root folder. Reason: \(error.debugDescription)")
            }
        }
        return image
    }
    
    
    
    
}
