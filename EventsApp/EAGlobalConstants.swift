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
    static let NOTIFICATION_EVENT_FOLDERS_RETRIEVED = Notification.Name("notification.event.folders.retrieved")
    static let NOTIFICATION_EVENT_FILES_RETRIEVED = Notification.Name("notification.event.files.retrieved")
    static let NOTIFICATION_EVENT_FILE_DOWNLOADED = Notification.Name("notification.event.file.downloaded")
    static let NOTIFICATION_USER_UNAUTHENTICATED = Notification.Name("notification.user.unathenticated")
    static let NOTIFICATION_IMAGE_UPLOAD_PROGRESS_UPDATE = Notification.Name("notification.image.upload.progress.update")
    static let NOTIFICATION_IMAGE_UPLOADED = Notification.Name("notification.image.uploaded")
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
    static let EXIT_GALLERY_SEGUE = "exitGalleryView"
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

struct UploadImageKeys {
    static let EVENT = "event"
    static let UPLOAD_PERCENTAGE = "uploadPecentage"
    static let IMAGE_NAME = "imageName"
}

struct AlertText {
    static let CREATE_OR_SELECT_EVENT_TITLE = "No event context"
    static let CREATE_OR_SELECT_EVENT_MESSAGE = "Create or select an event to upload pictures"
}



