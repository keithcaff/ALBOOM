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
    
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    private func getRootDirectory() -> URL {
        let root = getDocumentsDirectory().appendingPathComponent(DeviceFolderNames.EA_ROOT_DEVICE_FOLDER, isDirectory: true)
        return root
    }
    
    private func createRootFolder() {
        let rootDirectory = getRootDirectory()
        if !FileManager.default.fileExists(atPath: rootDirectory.path) {
            do {
                try FileManager.default.createDirectory(atPath: rootDirectory.path, withIntermediateDirectories: false, attributes: nil)
            }
            catch let error as NSError {
                print("Failed to create root folder. Reason: \(error.debugDescription)")
            }
        }
    }
    
    open func writeFileToRootFolder(fileName:String , data:Data ) {
        if (self.rootFolder == nil || !FileManager.default.fileExists(atPath: self.rootFolder!)) {
            createRootFolder()
        }
        let file = getDocumentsDirectory().appendingPathComponent(DeviceFolderNames.EA_ROOT_DEVICE_FOLDER, isDirectory: true).appendingPathComponent(fileName, isDirectory:false).appendingPathExtension(DeviceFolderNames.EA_IMAGE_FILE_TYPE)
        do {
            try data.write(to: file)
        }
        catch let error as NSError {
            print("Failed to writeFileToRootFolder. Reason: \(error.debugDescription)")
        }
    }
    
    open func getImageFromFile(fileId:String) -> UIImage? {
        var image:UIImage?
        let file = getDocumentsDirectory().appendingPathComponent(DeviceFolderNames.EA_ROOT_DEVICE_FOLDER, isDirectory: true).appendingPathComponent(fileId, isDirectory:false).appendingPathExtension(DeviceFolderNames.EA_IMAGE_FILE_TYPE)
        do {
            let imageData =  try Data(contentsOf: file)
            image = UIImage(data: imageData)
            print("Retrieved image from file. Path: \(file.path)")
        }
        catch let error as NSError {
            print("Failed to get image from file. Reason: \(error.debugDescription)")
            print("Failed to get image from file. Path: \(file.path)")
            do {
                let fileNames = try FileManager.default.contentsOfDirectory(atPath: getRootDirectory().path)
                for fileName in fileNames {
                    print("fileName: \(fileName) fileId: \(fileId) matches: \(fileId == fileName)")
                }
            }
            catch let error as NSError {
                print("Failed to list file names : \(error.debugDescription)")
            }
        }
        return image
    }
    
    open func cleanupStoredData() {
        let rootDirectory = getRootDirectory()
        if FileManager.default.fileExists(atPath: rootDirectory.path) {
            do {
                let fileNames = try FileManager.default.contentsOfDirectory(atPath: getRootDirectory().path)
                for fileName in fileNames {
                    let fileToRemove = rootDirectory.appendingPathComponent(fileName, isDirectory:false)
                    try FileManager.default.removeItem(at: fileToRemove)
                }
                let files = try FileManager.default.contentsOfDirectory(atPath: getRootDirectory().path)
                print("all files in cache after deleting images: \(files)")
                try FileManager.default.removeItem(at: rootDirectory)
            }
            catch let error as NSError {
                print("Failed to cleanupStoredData. Reason: \(error.debugDescription)")
            }
        }
    }
}
