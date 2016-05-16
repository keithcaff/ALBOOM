//
//  ViewController.swift
//  EventsApp
//
//  Created by Keith Caffrey on 16/05/2016.
//  Copyright © 2016 KC. All rights reserved.
//
import UIKit
import GoogleAPIClient
import GTMOAuth2

class EAMainViewController: UIViewController {
    
    private let kKeychainItemName = "Drive API"
    private let kClientID = "991511781552-7bfr8vmtbn9pm6rpsraov4qrde714rpu.apps.googleusercontent.com"
    
    // If modifying these scopes, delete your previously saved credentials by
    // resetting the iOS simulator or uninstall the app.
    private let scopes = [kGTLAuthScopeDriveReadonly]
    private let service = GTLServiceDrive()
    
    @IBOutlet var loginButton: UIButton!
    @IBOutlet var output: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let auth = GTMOAuth2ViewControllerTouch.authForGoogleFromKeychainForName(
            kKeychainItemName,
            clientID: kClientID,
            clientSecret: nil) {
            service.authorizer = auth
        }
        
    }
    
    
    @IBAction func loginClicked(sender: AnyObject) {
        if let authorizer = service.authorizer,
            canAuth = authorizer.canAuthorize where canAuth {
            fetchFiles()
        }
        else {
            presentViewController(
                createAuthController(),
                animated: true,
                completion: nil
            )
        }
    }
    
    
    // When the view appears, ensure that the Drive API service is authorized
    // and perform API calls
    override func viewDidAppear(animated: Bool) {
        if let authorizer = service.authorizer, canAuth = authorizer.canAuthorize where canAuth {
            loginButton.hidden = true;
            fetchFiles()
        }
        else {
            loginButton.hidden = false;
        }
    }
    
    // Construct a query to get names and IDs of 10 files using the Google Drive API
    func fetchFiles() {
        output.text = "Getting files..."
        let query = GTLQueryDrive.queryForFilesList()
        query.pageSize = 10
        query.fields = "nextPageToken, files(id, name)"
        service.executeQuery(
            query,
            delegate: self,
            didFinishSelector: "displayResultWithTicket:finishedWithObject:error:"
        )
    }
    
    // Parse results and display
    func displayResultWithTicket(ticket : GTLServiceTicket,
                                 finishedWithObject response : GTLDriveFileList,
                                                    error : NSError?) {
        
        if let error = error {
            showAlert("Error", message: error.localizedDescription)
            return
        }
        
        var filesString = ""
        
        if let files = response.files where !files.isEmpty {
            filesString += "Files:\n"
            for file in files as! [GTLDriveFile] {
                filesString += "\(file.name) (\(file.identifier))\n"
            }
        } else {
            filesString = "No files found."
        }
        
        output.text = filesString
    }

    
    
    // Creates the auth controller for authorizing access to Drive API
    private func createAuthController() -> GTMOAuth2ViewControllerTouch {
        let scopeString = scopes.joinWithSeparator(" ")
        return GTMOAuth2ViewControllerTouch(
            scope: scopeString,
            clientID: kClientID,
            clientSecret: nil,
            keychainItemName: kKeychainItemName,
            delegate: self,
            finishedSelector: "viewController:finishedWithAuth:error:"
        )
    }
    
    
    
    // Handle completion of the authorization process, and update the Drive API
    // with the new credentials.
    func viewController(vc : UIViewController, finishedWithAuth authResult : GTMOAuth2Authentication, error : NSError?) {
        
        if let error = error {
            service.authorizer = nil
            showAlert("Authentication Error", message: error.localizedDescription)
            return
        }
        
        service.authorizer = authResult
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    // Helper for showing an alert
    func showAlert(title : String, message: String) {
        let alert = UIAlertView(
            title: title,
            message: message,
            delegate: nil,
            cancelButtonTitle: "OK"
        )
        alert.show()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

