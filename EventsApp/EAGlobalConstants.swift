//
//  GlobalConstants.swift
//  EventsApp
//
//  Created by Keith Caffrey on 21/07/2016.
//  Copyright © 2016 KC. All rights reserved.
//

import Foundation

//Google Constants
let EVENT_FOLDER_PREFIX:String = "Event_App_"
let APP_NAME = "EventsApp"

//Notification Constants
extension Notification.Name {
    static let NOTIFICATION_EVENT_FOLDER_CREATED = Notification.Name("notification.event.folder.created")
    static let NOTIFICATION_EVENT_FOLDER_DELETED = Notification.Name("notification.event.folder.deleted")
    static let NOTIFICATION_EVENT_FOLDER_SHARED = Notification.Name("notification.event.folder.shared")
    static let NOTIFICATION_EVENT_SHARE_FAILED = Notification.Name("notification.event.share.failed")
    static let NOTIFICATION_EVENT_FOLDERS_RETRIEVED = Notification.Name("notification.event.folders.retrieved")
    static let NOTIFICATION_EVENT_FOLDERS_RETRIEVAL_FAILED = Notification.Name("notification.event.folders.retrieval.failed")
    static let NOTIFICATION_EVENT_FILES_RETRIEVED = Notification.Name("notification.event.files.retrieved")
    static let NOTIFICATION_EVENT_LATEST_FILES_RETRIEVED = Notification.Name("notification.event.latest.files.retrieved")
    static let NOTIFICATION_EVENT_FAILED_TO_GET_LATEST_FILES = Notification.Name("notification.event.failed.get.latest.files")
    static let NOTIFICATION_EVENT_FILE_DOWNLOADED = Notification.Name("notification.event.file.downloaded")
    static let NOTIFICATION_USER_UNAUTHENTICATED = Notification.Name("notification.user.unathenticated")
    static let NOTIFICATION_IMAGE_UPLOAD_PROGRESS_UPDATE = Notification.Name("notification.image.upload.progress.update")
    static let NOTIFICATION_IMAGE_UPLOADED = Notification.Name("notification.image.uploaded")
    static let NOTIFICATION_IMAGE_UPLOAD_FAILED = Notification.Name("notification.image.upload.failed")
}


//User defaults keys
let DEFAULT_CURRENT_EVENT_NAME:String! = "user.defaults.current.event.name"
let DEFAULT_CURRENT_EVENT_ID:String! = "user.defaults.current.event.id"

//Segue Constants
struct SegueIdentifiers {
    static let EXIT_VIEW_EVENTS_UNWIND_SEGUE = "exitViewEventsUnwindSegue"
    static let CREATE_EVENT_SEGUE = "createEventSegue"
    static let CREATE_EVENT_UNWIND_SEGUE = "createEventUnWind"
    static let VIEW_EVENTS_SEGUE = "viewEventsSegue"
    static let VIEW_ABOUT_APP_SEGUE = "viewAboutAppSegue"
    static let EXIT_GALLERY_SEGUE = "exitGalleryView"
    static let SHARE_EVENT_SEGUE = "shareEventSegue"
}


//XIB Identifiers
struct XIBIdentifiers {
    static let XIB_VIEW_EVENT_CELL_IDENTIFIER:String! = "EAViewEventTableViewCell"
    static let XIB_HOME_CELL_IDENTIFIER:String! = "EAHomeTableViewCell"
    static let XIB_IMAGE_UPLOAD_CELL_IDENTIFIER:String! = "EAImageUploadTableViewCell"
}

struct MenuItemLabels {
    static let CREATE_EVENT = "Create Event"
    static let VIEW_EVENTS = "View Events"
    static let SHARE_EVENTS = "Share Events"
    static let ABOUT_APP = "About"
    static let LOG_OUT = "Log Out"
}

struct StoryBoardIdentifiers {
    static let MAIN_STORYBOARD = "EAMain"
}

struct RestorationIdentifiers {
    static let CAMERA_NAVIGATION_VIEW_CONTROLLER = "EACameraNavVC"
}

struct ViewControllerIdentifiers {
    static let LOGIN_VIEW_CONTROLLER = "LoginViewController"
    static let ROOT_SW_REVEAL_VIEW_CONTROLLER = "RootSWRevealViewController"
}

struct GoogleAPIKeys {
    static let EVENT = "event"
    static let EVENT_ID = "eventId"
    static let DRIVE_FILES = "driveFiles"
    static let UPLOAD_PERCENTAGE = "uploadPecentage"
    static let IMAGE_NAME = "imageName"
    static let IMAGE_UPLOAD = "imageUpload"
    
}

struct DeviceFolderNames {
    static let EA_ROOT_DEVICE_FOLDER = "EARoot"
    static let EA_IMAGE_FILE_TYPE = "jpg"
}

struct EAUIText {
    static let ALERT_UNAUTHORISED_TITLE = "User unauthorised"
    static let ALERT_UNAUTHORISED_MESSAGE = "Please login to continue"
    static let ALERT_UPLOAD_COMPLETE_TITLE = "Upload complete"
    static let ALERT_UPLOAD_COMPLETE_MESSAGE = "Media uploaded to Google Drive"
    static let EAHOME_TABLE_VIEW_REFRESH_CONTROL_TITLE = "Fetching latest files"
    static let EAVIEW_EVENTS_TABLE_VIEW_REFRESH_CONTROL_TITLE = "Fetching latest event folders"
    static let ALERT_CREATE_OR_SELECT_EVENT_TITLE = "No event context"
    static let ALERT_CREATE_OR_SELECT_EVENT_MESSAGE = "Create or select an event to upload media"
    static let ALERT_SHARE_EVENT_FAILED_TITLE = "Share Failed"
    static let ALERT_EVENT_SHARED_SUCCESSFULLY_TITLE = "Event Shared"
    static let ALERT_EVENT_SHARED_SUCCESSFULLY_MESSAGE = "Successfully shared event"
    static let ALERT_SHARE_EVENT_FAILED_MESSAGE = "An error occured sharing selected event"
    static let ALERT_OK_ACTION_TITLE = "Ok"
    static let SHARE_SINGLE_IMAGE_TEXT = "Media shared from \(APP_NAME). Available on app store"
    static let SHARE_EVENT_TITLE_PREFIX = "Share"
    static let SHARE_EVENT_TITLE_SUFFIX = "event"
    static let ABOUT_APP_DEVELOPED_BY_HEADING = "Developed By"
    static let ABOUT_APP_DEVELOPED_BY_BODY = "Keith Caffrey \nLinkedIn:http://www.linkedin.com/in/keithcaffrey/ \nGithub: https://github.com/keithcaff"
    static let ABOUT_APP_ICONS_HEADING = "App Icons"
    static let ABOUT_APP_ICONS_BODY = "Navigation Icons used in this application were taken from https://icons8.com/ \nThe main app icon(polaroid-camera) was made by Webalys Freebies (http://www.streamlineicons.com/) and taken from Webalys Freebies www.flaticon.com."
    static let ABOUT_APP_MAIN_HEADING = "About \(APP_NAME)"
    static let ABOUT_APP_MAIN_BODY = "\(APP_NAME) uses Google Drive™ API to create folders for events. \(APP_NAME) allows you to create a Drive folder for an upcoming or past event. You can share this Drive folder with friends allowing them to add media content they have gathered."
    static let SHARE_EVENT_INFO_TEXT = "*We recommend sharing events with other Google users so they can add content via the \(APP_NAME)"
}

struct EAUIColours {
    static let REFRESH_CONTROL_TINT_COLOUR = UIColor.white
    static let PRIMARY_BLUE = UIColor(red: 0/255, green: 105.0/255, blue: 217/255, alpha: 1.0)
    static let SECONDARY_BLUE = UIColor(red: 59/255, green: 153/255, blue: 252/255, alpha: 1.0)
}


