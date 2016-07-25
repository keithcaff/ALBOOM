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
    private init() {}
    private let gtlServiceDrive = GTLServiceDrive()
    
    func setAuthorizerForService(signIn:GIDSignIn,user:GIDGoogleUser, service:GTLService) {
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

    
    func createEventFolder(event:EAEvent) {
        let service:GTLService = gtlServiceDrive
        setAuthorizerForService(GIDSignIn.sharedInstance(), user: GIDSignIn.sharedInstance().currentUser,service:service)
        service.setExactUserAgent(GIDSignIn.sharedInstance().currentUser.userID)
        print("Creating event folder %event")
        let folder:GTLDriveFile =  GTLDriveFile() ;
        folder.name = EVENT_FOLDER_PREFIX+event.name!
        folder.mimeType = "application/vnd.google-apps.folder";
        let query:GTLQueryDrive = GTLQueryDrive.queryForFilesCreateWithObject(folder,uploadParameters:nil)
        
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
                NSNotificationCenter.defaultCenter().postNotificationName(NOTIFICATION_EVENT_FOLDER_CREATED, object: createdFolder)
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
        service.executeQuery(query) { (ticket: GTLServiceTicket!, object: AnyObject!, error: NSError!) -> Void in
            if(error != nil){
                print("Error :\(error.localizedDescription)")
                return
            }
            print("object:  \(object)")
        }
    }
    
    
//    GTLServiceDrive *drive = ...;
//    NSString *parentId = @"root";
//    
//    GTLQueryDrive *query = [GTLQueryDrive queryForFilesList];
//    query.q = [NSString stringWithFormat:@"'%@' in parents", parentId];
//    [drive executeQuery:query completionHandler:^(GTLServiceTicket *ticket,
//    GTLDriveFileList *fileList,
//    NSError *error) {
//    if (error == nil) {
//    NSLog(@"Have results");
//    // Iterate over fileList.files array
//    } else {
//    NSLog(@"An error occurred: %@", error);
//    }
//    }];
    
    // Construct a query to get names and IDs of 10 files using the Google Drive API
    func fetchFiles() {
        let service:GTLService = gtlServiceDrive
        setAuthorizerForService(GIDSignIn.sharedInstance(), user: GIDSignIn.sharedInstance().currentUser,service:service)
        print("Getting files...")
        let query = GTLQueryDrive.queryForFilesList()
        query.pageSize = 10
        query.q = "'0By-3eIhKXJNzRmVDckY4WlcwVDQ' in parents"
        query.fields = "nextPageToken, files(id, name)"
        service.executeQuery(query) { (ticket: GTLServiceTicket!, object: AnyObject!, error: NSError!) -> Void in
            if(error != nil){
                print("Error: \(error)")
                return
            }
            print("object:  \(object)")
        }
    }
    
    
    func getAllEventFolders() {
        let service:GTLService = gtlServiceDrive
        setAuthorizerForService(GIDSignIn.sharedInstance(), user: GIDSignIn.sharedInstance().currentUser,service:service)
        print("Getting files...")
        let query = GTLQueryDrive.queryForFilesList()
        query.pageSize = 20//and name contains '\(EVENT_FOLDER_PREFIX)'
        query.q = "mimeType='application/vnd.google-apps.folder' and 'root' in parents and name contains '\(EVENT_FOLDER_PREFIX)' and trashed = false"
        query.fields = "nextPageToken, files(id, name)"
        service.executeQuery(query) { (ticket: GTLServiceTicket!, folders: AnyObject!, error: NSError!) -> Void in
            if(error != nil){
                print("Error: \(error)")
                return
            }
            print("successfully retrieved folders:  \(folders)")
            dispatch_async(dispatch_get_main_queue()) {
                NSNotificationCenter.defaultCenter().postNotificationName(NOTIFICATION_EVENT_FOLDERS_RETRIEVED, object: folders)
            }
        }

    }
    
    
   
}