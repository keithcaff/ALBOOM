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
        }
        return image
    }
    
    
    open func deleteFile(fileId:String) {
        let file = getDocumentsDirectory().appendingPathComponent(DeviceFolderNames.EA_ROOT_DEVICE_FOLDER, isDirectory: true).appendingPathComponent(fileId, isDirectory:false).appendingPathExtension(DeviceFolderNames.EA_IMAGE_FILE_TYPE)
        
        if FileManager.default.fileExists(atPath:file.path) {
            do {
                try FileManager.default.removeItem(at: file)
            }
            catch  {
                print("Failed to delete file. Reason: \(error) \n Path: \(file.path)")
            }
        }
        printSortedFiles()
    }
    
    func printSortedFiles() {
        var fileNames = [String]()
        let keys = [URLResourceKey.contentModificationDateKey]
        
        guard let fullPaths = try? FileManager.default.contentsOfDirectory(at: getRootDirectory(), includingPropertiesForKeys:keys, options: FileManager.DirectoryEnumerationOptions.skipsHiddenFiles) else {
            print("No files in directory")
            return
        }
        
        let orderedFullPaths = fullPaths.sorted(by: { (url1: URL, url2: URL) -> Bool in
            do {
                let values1 = try url1.resourceValues(forKeys: [.creationDateKey, .contentModificationDateKey])
                let values2 = try url2.resourceValues(forKeys: [.creationDateKey, .contentModificationDateKey])
                
                if let date1 = values1.creationDate, let date2 = values2.creationDate {
                    //if let date1 = values1.contentModificationDate, let date2 = values2.contentModificationDate {
                    return date1.compare(date2) == ComparisonResult.orderedDescending
                }
            } catch _{
                
            }
            return true
        })
        
        for fileName in orderedFullPaths {
            do {
                let values = try fileName.resourceValues(forKeys: [.creationDateKey, .contentModificationDateKey])
                if let date = values.creationDate{
                    //let date : Date? = values.contentModificationDate
                    print(fileName.lastPathComponent, " ", date)
                    let theFileName = fileName.lastPathComponent
                    fileNames.append(theFileName)
                }
            }
            catch _{
                
            }
        }
        fileNames.forEach { item in
            print("file: \(item)" )
        }
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
