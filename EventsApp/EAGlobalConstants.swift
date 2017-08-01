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


//Notification Constants
extension Notification.Name {
    static let NOTIFICATION_EVENT_FOLDER_CREATED = Notification.Name("notification.event.folder.created")
    static let NOTIFICATION_EVENT_FOLDER_DELETED = Notification.Name("notification.event.folder.deleted")
    static let NOTIFICATION_EVENT_FOLDERS_RETRIEVED = Notification.Name("notification.event.folders.retrieved")
    static let NOTIFICATION_EVENT_FILES_RETRIEVED = Notification.Name("notification.event.files.retrieved")
    static let NOTIFICATION_EVENT_FILE_DOWNLOADED = Notification.Name("notification.event.file.downloaded")
}


//User defaults keys
let DEFAULT_CURRENT_EVENT_NAME:String! = "user.defaults.current.event.name"
let DEFAULT_CURRENT_EVENT_ID:String! = "user.defaults.current.event.id"

//Segue Constants
let EXIT_VIEW_EVENTS_UNWIND_SEGUE:String! = "exitViewEventsUnwindSegue"
let CREATE_EVENT_SEGUE:String! = "createEventSegue"
let VIEW_EVENTS_SEGUE:String! = "viewEventsSegue"


//NIB Identifiers
let NIB_VIEW_EVENT_CELL_IDENFIER:String! = "EAViewEventTableViewCell"
let NIB_HOME_CELL_IDENFIER:String! = "EAHomeTableViewCell"

//Cell identifiers
let CELL_VIEW_EVENT_IDENTIFIER:String! = "cell.view.event"
let CELL_HOME_IDENTIFIER:String! = "cell.home"

struct EAMenuItemLabels {
    public static let CREATE_EVENT = "Create Event"
    static let VIEW_EVENTS = "View Events"
    static let LOG_OUT = "Log Out"
}
