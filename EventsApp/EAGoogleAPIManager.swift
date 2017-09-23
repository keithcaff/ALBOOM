//
//  EAGoogleAPIManager.swift
//  EventsApp
//
//  Created by Keith Caffrey on 21/07/2016.
//  Copyright © 2016 KC. All rights reserved.
//

import Foundation
import GoogleAPIClient
import GTMOAuth2

class EAGoogleAPIManager {
    static let sharedInstance = EAGoogleAPIManager()
    fileprivate init() {}
    fileprivate let gtlServiceDrive = GTLServiceDrive()
    
    func setAuthorizerForService(_ signIn:GIDSignIn,user:GIDGoogleUser, service:GTLService) {
        if service.authorizer == nil {
            let auth:GTMOAuth2Authentication = GTMOAuth2Authentication()
            auth.clientID = signIn.clientID
            auth.userEmail = user.profile.email;
            auth.userID = user.userID
            auth.accessToken = user.authentication.accessToken
            auth.refreshToken = user.authentication.refreshToken
            auth.expirationDate = user.authentication.accessTokenExpirationDate
            service.authorizer = auth
        }
    }

    func createEventFolder(_ event:EAEvent) {
        let service:GTLService = gtlServiceDrive
        setAuthorizerForService(GIDSignIn.sharedInstance(), user: GIDSignIn.sharedInstance().currentUser,service:service)
        service.setExactUserAgent(GIDSignIn.sharedInstance().currentUser.userID)
        print("Creating event folder %event")
        let folder:GTLDriveFile =  GTLDriveFile() ;
        folder.name = EVENT_FOLDER_PREFIX+event.name!
        folder.mimeType = "application/vnd.google-apps.folder";
        let query:GTLQueryDrive = GTLQueryDrive.queryForFilesCreate(withObject: folder,uploadParameters:nil)
        
        service.executeQuery(query, completionHandler:  { (ticket, createdFolder , error) -> Void in
            if let error = error {
                self.handleGoogleAPIError(error)
            }
            else {
                print("success crated folder: \(createdFolder)")
                NotificationCenter.default.post(name: .NOTIFICATION_EVENT_FOLDER_CREATED, object: createdFolder)
            }
        })
    }
    
    func getRootEventAppFolder() {
        let service:GTLService = gtlServiceDrive
//        GTLQueryDrive *queryFilesList = [GTLQueryDrive queryForChildrenListWithFolderId:@"root"];
//        queryFilesList.q = @"mimeType='application/vnd.google-apps.folder'";
        let query:GTLQueryDrive = GTLQueryDrive.queryForFilesList()
        query.q = "mimeType='application/vnd.google-apps.folder' and 'root' in parents and trashed=false";
        setAuthorizerForService(GIDSignIn.sharedInstance(), user: GIDSignIn.sharedInstance().currentUser,service:service)
        service.executeQuery(query, completionHandler: {(ticket: GTLServiceTicket?, object: Any?, error: Error?) in
            if let error = error {
                self.handleGoogleAPIError(error)
            }
            else {
                print("Root event folder retrieved:  \(object)")
            }
        })
    }
    
    func getAllEventFolders() {
        let service:GTLService = gtlServiceDrive
        setAuthorizerForService(GIDSignIn.sharedInstance(), user: GIDSignIn.sharedInstance().currentUser,service:service)
        print("Getting all event folders...")
        let query:GTLQueryDrive = GTLQueryDrive.queryForFilesList()
        query.pageSize = 20//and name contains '\(EVENT_FOLDER_PREFIX)'
        query.q = "mimeType='application/vnd.google-apps.folder' and 'root' in parents and name contains '\(EVENT_FOLDER_PREFIX)' and trashed = false"
        query.fields = "nextPageToken, files(id, name)"
        service.executeQuery(query, completionHandler:  { (ticket, folders , error) -> Void in
//            let testing401:Bool = true
            if let error = error {
                self.handleGoogleAPIError(error)
            }
//            else if testing401 {
//                let testError = NSError(domain: "KC_TEST_ERROR", code: 401, userInfo: nil)
//                self.handleGoogleAPIError(testError)
//            }
            else {
                print("successfully retrieved folders:  \(folders)")
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: .NOTIFICATION_EVENT_FOLDERS_RETRIEVED, object: folders)
                }
            }
        })
    }
    
    func switchEventFolder(_ event:EAEvent) {
        let service:GTLService = gtlServiceDrive
        setAuthorizerForService(GIDSignIn.sharedInstance(), user: GIDSignIn.sharedInstance().currentUser,service:service)
        print("Getting files inside event folder")
        let parentId:String  = event.id!;
        let query:GTLQueryDrive  = GTLQueryDrive.queryForFilesList()
        query.q = "'\(parentId)' in parents and trashed = false"
        query.fields = "nextPageToken, files(id, name)"
        service.executeQuery(query, completionHandler: {(ticket: GTLServiceTicket?, files:Any?, error:Error?) in
            if let error = error {
                self.handleGoogleAPIError(error)
            }
            else {
                let defaults = UserDefaults.standard
                defaults.set(event.name, forKey: DEFAULT_CURRENT_EVENT_NAME)
                defaults.set(event.id, forKey: DEFAULT_CURRENT_EVENT_ID)
                print("successfully retrieved files:  \(files)")
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: .NOTIFICATION_EVENT_FILES_RETRIEVED, object: files)
                }
            }
        })
    }
    
    func downloadFile(_ file:GTLDriveFile!) {
        let service:GTLService = gtlServiceDrive
        setAuthorizerForService(GIDSignIn.sharedInstance(), user: GIDSignIn.sharedInstance().currentUser,service:service)
        print("Downloading file \(file)")
        let stringURL:String = "https://www.googleapis.com/drive/v3/files/\(file.identifier!)?alt=media"
        let url:URL = URL(string: stringURL)!
        let fetcher:GTMSessionFetcher = service.fetcherService.fetcher(with: url)
        fetcher.setProperty(file.identifier, forKey:"fileId")
        fetcher.beginFetch { (data:Data?, error:Error?) in
            if let error = error {
                self.handleGoogleAPIError(error)
            }
            else {
                let fetcherProperties: Dictionary<String,String>! = [
                    "fileId": (fetcher.properties!["fileId"] as! String)
                ]
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: .NOTIFICATION_EVENT_FILE_DOWNLOADED, object: data, userInfo:fetcherProperties )
                }
            }
        }
    }
    
    
    
    func uploadImageToEvent(_ image:UIImage, event:EAEvent) {
        let service:GTLService = gtlServiceDrive
        setAuthorizerForService(GIDSignIn.sharedInstance(), user: GIDSignIn.sharedInstance().currentUser,service:service)
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .medium
        
        let file : GTLDriveFile = GTLDriveFile()
        
        file.name = "\(dateFormatter.string(from:Date()))_\(APP_NAME).jpg"
        file.descriptionProperty = "File uploaded with \(APP_NAME)"
        
        // set the folder to where the file is going to be uploaded
        file.parents = [event.id!]
        file.mimeType = "image/jpg"
        
        guard let data : NSData = UIImageJPEGRepresentation(image, 1) as NSData? else {
            assertionFailure("could not create jpeg representation from image")
            return
        }
        
        let uploadParameters : GTLUploadParameters = GTLUploadParameters(data: data as Data, mimeType: file.mimeType)
        
        
        let query = GTLQueryDrive.queryForFilesCreate(withObject: file, uploadParameters: uploadParameters)
        
        let uploadBlock : GTLServiceUploadProgressBlock = {(ticket:GTLServiceTicket?,
                                                           totalBytesUploaded:UInt64,
                                                           totalBytesExpectedToUpload:UInt64) in
            
            print("Uploaded: \(totalBytesUploaded) out of \(totalBytesExpectedToUpload) bytes")
            
            let percentageUploaded = totalBytesUploaded/totalBytesExpectedToUpload
            
            let uploadDetails:[String:Any] = [UploadImageKeys.UPLOAD_PERCENTAGE:percentageUploaded, UploadImageKeys.IMAGE_NAME:file.name]
            NotificationCenter.default.post(name: .NOTIFICATION_IMAGE_UPLOADED, object: uploadDetails)
        }
        
        DispatchQueue.main.async {
            let uploadTicket: GTLServiceTicket = service.executeQuery(query!, completionHandler: {
                (ticket: GTLServiceTicket?, id:Any?, error:Error?) in
                
                if let error = error {
                    self.handleGoogleAPIError(error)
                }
                
                else {
                    print("file uploaded successfully!!! \(id)")
                    NotificationCenter.default.post(name: .NOTIFICATION_IMAGE_UPLOADED, object: event)
                }
            })
            
            uploadTicket.uploadProgressBlock = uploadBlock
        }
    }
    
    
    func deleteEvent(_ event:EAEvent) {
        let service:GTLService = gtlServiceDrive
        setAuthorizerForService(GIDSignIn.sharedInstance(), user: GIDSignIn.sharedInstance().currentUser,service:service)
        print("Deleting folder")
        let parentId:String  = event.id!;
        let query:GTLQueryDrive  = GTLQueryDrive.queryForFilesDelete(withFileId: parentId)
        service.executeQuery(query, completionHandler: {(ticket: GTLServiceTicket?, id:Any?, error:Error?) in
            if let error = error {
                self.handleGoogleAPIError(error)
            }
            else {
                print("deleted file successfully!!! \(id)")
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: .NOTIFICATION_EVENT_FOLDER_DELETED, object: event)
                }
            }
        })
    }
    
    func handleGoogleAPIError(_ error:Error) {
        print("EAGoogleAPIManager-Error: \(error)")
        let nserror:NSError! = error as NSError
        switch nserror.code {
            case 401:
                self.postUnAuthenticatedNotifcation()
                break;
            default:
                break;
        }
    }

    func postUnAuthenticatedNotifcation() {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .NOTIFICATION_USER_UNAUTHENTICATED, object: nil)
        }
    }
   
}
