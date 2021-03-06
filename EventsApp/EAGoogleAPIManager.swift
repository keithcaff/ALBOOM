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
    let imagefileExtensions = "(fileExtension = 'jpeg' or fileExtension = 'jpg' or fileExtension = 'png' or fileExtension ='tiff' or fileExtension ='tif' or fileExtension ='gif')"
    static let sharedInstance = EAGoogleAPIManager()
    fileprivate init() {}
    fileprivate let gtlServiceDrive = GTLServiceDrive()
    
    func setAuthorizerForService(_ signIn:GIDSignIn,user:GIDGoogleUser, service:GTLService) {
        let auth:GTMOAuth2Authentication = GTMOAuth2Authentication()
        auth.clientID = signIn.clientID
        auth.userEmail = user.profile.email;
        auth.userID = user.userID
        auth.accessToken = user.authentication.accessToken
        auth.refreshToken = user.authentication.refreshToken
        auth.expirationDate = user.authentication.accessTokenExpirationDate
        service.authorizer = auth
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
                if let folder = createdFolder {
                    print("success crated folder: \(folder)")
                    NotificationCenter.default.post(name: .NOTIFICATION_EVENT_FOLDER_CREATED, object: folder)
                }
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
                if let root = object {
                    print("Root event folder retrieved:  \(root)")
                }
            }
        })
    }
    
    func getAllEventFolders() {
        let service:GTLService = gtlServiceDrive
        setAuthorizerForService(GIDSignIn.sharedInstance(), user: GIDSignIn.sharedInstance().currentUser,service:service)
        print("Getting all event folders...")
        let query:GTLQueryDrive = GTLQueryDrive.queryForFilesList()
        query.q = "mimeType='application/vnd.google-apps.folder' and ('root' in parents and name contains '\(EVENT_FOLDER_PREFIX)' and trashed = false) or (name contains '\(EVENT_FOLDER_PREFIX)' and sharedWithMe = true)"
//        query.fields = "nextPageToken, files(id, name, imageMediaMetadata, createdTime, appProperties)"
        query.fields = "*"
        service.executeQuery(query, completionHandler:  { (ticket, folders , error) -> Void in
            if let error = error {
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: .NOTIFICATION_EVENT_FOLDERS_RETRIEVAL_FAILED, object: nil)
                }
                self.handleGoogleAPIError(error)
            }
            else {
                if let folders = folders {
                    print("successfully retrieved folders:  \(folders)")
                }
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
        query.q = "'\(parentId)' in parents and trashed = false and \(imagefileExtensions)"
//        query.fields = "nextPageToken, files(id, name, contentHints, imageMediaMetadata, createdTime, appProperties)"
        query.fields = "*"
        service.executeQuery(query, completionHandler: {(ticket: GTLServiceTicket?, files:Any?, error:Error?) in
            if let error = error {
                self.handleGoogleAPIError(error)
            }
            else {
                let defaults = UserDefaults.standard
                defaults.set(event.name, forKey: DEFAULT_CURRENT_EVENT_NAME)
                defaults.set(event.id, forKey: DEFAULT_CURRENT_EVENT_ID)
                if let files = files {
                    print("successfully retrieved files:  \(files)")
                }
                
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: .NOTIFICATION_EVENT_FILES_RETRIEVED, object: files)
                }
            }
        })
    }
    
//    func getImageFilesOnly(filesList:GTLDriveFileList) -> {
//        if let files = filesList.files {
//            let images = files.filter {
//                file.fileExtension == "jpg"
//            }
//        }
//    }
    
    func getLatestFilesForEvent(_ event:EAEvent) {
        let service:GTLService = gtlServiceDrive
        setAuthorizerForService(GIDSignIn.sharedInstance(), user: GIDSignIn.sharedInstance().currentUser,service:service)
        print("Getting files inside event folder")
        let parentId:String  = event.id!;
        let query:GTLQueryDrive  = GTLQueryDrive.queryForFilesList()
        query.q = "'\(parentId)' in parents and trashed = false and \(imagefileExtensions)"
        
//        query.fields = "nextPageToken, files(id, name, contentHints, imageMediaMetadata, createdTime, appProperties)"
        query.fields = "*"
        
        service.executeQuery(query, completionHandler: {(ticket: GTLServiceTicket?, files:Any?, error:Error?) in
            if let error = error {
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: .NOTIFICATION_EVENT_FAILED_TO_GET_LATEST_FILES, object: files)
                }
                self.handleGoogleAPIError(error)
            }
            else {
                if let files = files {
                    print("successfully retrieved files:  \(files)")
                }
                let fileDetails:[String:Any] = [GoogleAPIKeys.DRIVE_FILES:files != nil ? files! : GTLDriveFileList(), GoogleAPIKeys.EVENT_ID:event.id!]
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: .NOTIFICATION_EVENT_LATEST_FILES_RETRIEVED, object: files, userInfo:fileDetails)
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
                print("DOWNLOAD FAILED!!!!!!!!!!!!!!!")
                NotificationCenter.default.post(name: .NOTIFICATION_EVENT_FILE_DOWNLOAD_FAILED, object: file)
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
    
    
    func updateFile(_ file1:GTLDriveFile, withTags tags:[String] = ["Keith test"]) {
        //https://developers.google.com/drive/v2/reference/files/update
        //https://developers.google.com/drive/v2/reference/files/patch#examples
        //https://developers.google.com/drive/v2/reference/files/patch
        //https://developers.google.com/drive/v3/web/properties
        //https://developers.google.com/drive/v3/web/search-parameters
        let service:GTLService = gtlServiceDrive
        setAuthorizerForService(GIDSignIn.sharedInstance(), user: GIDSignIn.sharedInstance().currentUser,service:service)
        
        
        let file = GTLDriveFile()
        let tagDict: NSMutableDictionary = ["tags":"Keith,Work"]
        file.properties = GTLDriveFileProperties(json:tagDict)
        file.properties.setAdditionalProperty("test, test", forName: "tags2")
        
        let query = GTLQueryDrive.queryForFilesUpdate(withObject: file, fileId:file1.identifier, uploadParameters: nil)
        
        service.executeQuery(query!, completionHandler:  { (ticket, updatedFile , error) -> Void in
            if let error = error {
                self.handleGoogleAPIError(error)
            }
            else {
                if let updatedFile = updatedFile {
                    print("success updating file idexable text: \(updatedFile)")
                    //NotificationCenter.default.post(name: .NOTIFICATION_EVENT_FOLDER_CREATED, object: folder)
                }
            }
        })
    }
    
    func uploadImageToEvent(_ imageUpload:EAImageUpload, event:EAEvent) {
        let service:GTLService = gtlServiceDrive
        setAuthorizerForService(GIDSignIn.sharedInstance(), user: GIDSignIn.sharedInstance().currentUser,service:service)
        let file : GTLDriveFile = GTLDriveFile()
        
        file.name = imageUpload.name!
        file.descriptionProperty = "File uploaded with \(APP_NAME)"
        
        // set the folder to where the file is going to be uploaded
        file.parents = [event.id!]
        file.mimeType = "image/jpg"
        
        guard let data : NSData = UIImageJPEGRepresentation(imageUpload.image!, 1) as NSData? else {
            assertionFailure("could not create jpeg representation from image")
            return
        }
        
        let uploadParameters : GTLUploadParameters = GTLUploadParameters(data: data as Data, mimeType: file.mimeType)
        
        
        let query = GTLQueryDrive.queryForFilesCreate(withObject: file, uploadParameters: uploadParameters)
        
        let uploadBlock : GTLServiceUploadProgressBlock = {(ticket:GTLServiceTicket?,
                                                           totalBytesUploaded:UInt64,
                                                           totalBytesExpectedToUpload:UInt64) in
            
            print("Uploaded: \(totalBytesUploaded) out of \(totalBytesExpectedToUpload) bytes")
            
            let percentageUploaded:Float = ((Float(totalBytesUploaded)/Float(totalBytesExpectedToUpload))*100)
            
            let uploadDetails:[String:Any] = [GoogleAPIKeys.UPLOAD_PERCENTAGE:percentageUploaded, GoogleAPIKeys.IMAGE_NAME:file.name]
            NotificationCenter.default.post(name: .NOTIFICATION_IMAGE_UPLOAD_PROGRESS_UPDATE, object: uploadDetails)
        }
        
        DispatchQueue.main.async {
            let uploadTicket: GTLServiceTicket = service.executeQuery(query!, completionHandler: {
                (ticket: GTLServiceTicket?, id:Any?, error:Error?) in
                let uploadDetails:[String:Any] = [GoogleAPIKeys.EVENT:event, GoogleAPIKeys.IMAGE_UPLOAD:imageUpload]
                if let error = error {
                    NotificationCenter.default.post(name: .NOTIFICATION_IMAGE_UPLOAD_FAILED, object: uploadDetails)
                    self.handleGoogleAPIError(error)
                }
                else {
                    if let id = id {
                        print("file uploaded successfully!!! \(id)")
                    }
                    NotificationCenter.default.post(name: .NOTIFICATION_IMAGE_UPLOADED, object: uploadDetails)
                    self.getLatestFilesForEvent(event)
                }
            })
            
            uploadTicket.uploadProgressBlock = uploadBlock
        }
    }
    
    func shareEvent(_ event:EAEvent, withEmail email:String) {
        //https://developers.google.com/drive/v3/web/manage-sharing
        guard let fileId = event.id else {
            return
        }
        let service:GTLService = gtlServiceDrive
        setAuthorizerForService(GIDSignIn.sharedInstance(), user: GIDSignIn.sharedInstance().currentUser,service:service)
        print("Sharing event")
        
        let permission: GTLDrivePermission = GTLDrivePermission()
        permission.type = "user"
        permission.role = "writer"
        permission.emailAddress = email
        let query:GTLQueryDrive  = GTLQueryDrive.queryForPermissionsCreate(withObject: permission, fileId: fileId)
        //query.emailMessage = "\(EAUIText.EMAIL_MESSAGE_TEXT)"
        
        service.executeQuery(query, completionHandler: {(ticket: GTLServiceTicket?, id:Any?, error:Error?) in
            if let error = error {
                self.handleGoogleAPIError(error)
                if error._code != 401 {
                    NotificationCenter.default.post(name: .NOTIFICATION_EVENT_SHARE_FAILED, object: error.localizedDescription)
                }
            }
            else {
                if let name = event.name {
                    print("shared event successfully!!! \(name)")
                }
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: .NOTIFICATION_EVENT_FOLDER_SHARED, object: event)
                }
            }
        })
    }
    
    
    func shareEvent(_ event:EAEvent, withEmails emails:[String]) {
        //https://developers.google.com/drive/v3/web/manage-sharing
        guard let fileId = event.id else {
            return
        }
        let service:GTLService = gtlServiceDrive
        setAuthorizerForService(GIDSignIn.sharedInstance(), user: GIDSignIn.sharedInstance().currentUser,service:service)
        print("Sharing event for list of emails")
        let batchQuery: GTLBatchQuery = GTLBatchQuery()
        for email in emails {
            let permission: GTLDrivePermission = GTLDrivePermission()
            permission.type = "user"
            permission.role = "writer"
            permission.emailAddress = email
            let query:GTLQueryDrive  = GTLQueryDrive.queryForPermissionsCreate(withObject: permission, fileId: fileId)
            //query.emailMessage = "\(EAUIText.EMAIL_MESSAGE_TEXT)"
            batchQuery.addQuery(query)
        }

        service.executeQuery(batchQuery, completionHandler: {(ticket: GTLServiceTicket?, id:Any?, error:Error?) in
            if let error = error {
                self.handleGoogleAPIError(error)
                if error._code != 401 {
                    NotificationCenter.default.post(name: .NOTIFICATION_EVENT_SHARE_FAILED, object: error.localizedDescription)
                }
            }
            else {
                if let name = event.name {
                    print("shared event successfully!!! \(name)")
                }
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: .NOTIFICATION_EVENT_FOLDER_SHARED, object: event)
                }
            }
        })
    }
    
    @objc func displayResultWithTicketEachMessages(ticket : GTLServiceTicket, finishedWithObject eachMessageResponse : GTLBatchResult, error : NSError?) {
    
    
    }
    
    func deleteFile(_ file:GTLDriveFile, fromEvent event:EAEvent) {
        let service:GTLService = gtlServiceDrive
        setAuthorizerForService(GIDSignIn.sharedInstance(), user: GIDSignIn.sharedInstance().currentUser,service:service)
        print("Deleting file")
        let query:GTLQueryDrive  = GTLQueryDrive.queryForFilesDelete(withFileId: file.identifier)
        service.executeQuery(query, completionHandler: {(ticket: GTLServiceTicket?, id:Any?, error:Error?) in
            DispatchQueue.main.async {
                if let error = error {
                    self.handleGoogleAPIError(error)
                    print("Delete of file failed \(file.description)")
                    NotificationCenter.default.post(name: .NOTIFICATION_EVENT_FILE_DELETE_FAILED, object: file, userInfo:["event":event])
                }
                else {
                    if let name = event.name {
                        print("deleted \(file.description) file from \(name) event")
                    }
                    NotificationCenter.default.post(name: .NOTIFICATION_EVENT_FILE_DELETED, object: file, userInfo:["event":event])
                }
            }
        })
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
                if let name = event.name {
                    print("deleted file successfully!!! \(name)")
                }
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: .NOTIFICATION_EVENT_FOLDER_DELETED, object: event)
                }
            }
        })
    }
    
    func handleGoogleAPIError(_ error:Error) {
        print("EAGoogleAPIManager-Error: \(error)")
        let code = error._code
        switch code {
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
