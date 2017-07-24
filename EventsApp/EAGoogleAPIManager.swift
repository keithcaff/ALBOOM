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
        
       // weak var weakSelf:EAGoogleAPIManager! = self
        service.executeQuery(query, completionHandler:  { (ticket, createdFolder , error) -> Void in
            if let error = error {
                print("failed with error: \(error)")
                //TODO:if 401 error - showlogin screen...
            }
            else {
                print("success crated folder: \(createdFolder)")
                //weakSelf.hideMenu()
                //post some notification that an event was created with event name
                NotificationCenter.default.post(name: .NOTIFICATION_EVENT_FOLDER_CREATED, object: createdFolder)
            }
        })
    }
    
    
    //id of dit talk folder 0By-3eIhKXJNzRmVDckY4WlcwVDQ
    func getRootEventAppFolder() {
        let service:GTLService = gtlServiceDrive
//        GTLQueryDrive *queryFilesList = [GTLQueryDrive queryForChildrenListWithFolderId:@"root"];
//        queryFilesList.q = @"mimeType='application/vnd.google-apps.folder'";

        let query:GTLQueryDrive = GTLQueryDrive.queryForFilesList()
        query.q = "mimeType='application/vnd.google-apps.folder' and 'root' in parents and trashed=false";
        //weak var weakSelf:EAGoogleAPIManager! = self
        setAuthorizerForService(GIDSignIn.sharedInstance(), user: GIDSignIn.sharedInstance().currentUser,service:service)
        service.executeQuery(query, completionHandler: {(ticket: GTLServiceTicket?, object: Any?, error: Error?) in
            if(error != nil){
                print("Error :\(error?.localizedDescription)")
                return
            }
            print("object:  \(object)")
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
            if(error != nil){
                print("Error: \(error)")
                return
            }
            print("successfully retrieved folders:  \(folders)")
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .NOTIFICATION_EVENT_FOLDERS_RETRIEVED, object: folders)
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
            if(error != nil){
                print("Error: \(error)")
                return
            }
            let defaults = UserDefaults.standard
            defaults.set(event.name, forKey: DEFAULT_CURRENT_EVENT_NAME)
            print("successfully retrieved files:  \(files)")
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .NOTIFICATION_EVENT_FILES_RETRIEVED, object: files)
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
            if(error != nil){
                print("Error: \(error)")
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



   
}
