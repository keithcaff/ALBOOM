//
//  Event.swift
//  EventsApp
//
//  Created by Keith Caffrey on 14/07/2016.
//  Copyright © 2016 KC. All rights reserved.
//

import Foundation

class EAEvent:NSObject{
    var name:String?
    var id:String?
    
    init(id:String?,eventName:String?) {
        self.id = id
        self.name = eventName;
    }
    
    var displayName : String {
        var displayName = ""
        if let name = name, name.count >= 1 {
            if name.contains(EVENT_FOLDER_PREFIX) {
                let startIndex = name.index(name.startIndex, offsetBy: EVENT_FOLDER_PREFIX.count)
                displayName = String(name.suffix(from: startIndex))
            }
            else {
                displayName = name //new events don't have prefix.
            }
        }
        return displayName
    }
    
    static func getCurrentEventId() -> String {
        var eventId:String
        let defaults = UserDefaults.standard
        let currentEventId = defaults.string(forKey: DEFAULT_CURRENT_EVENT_ID)
        if let currentEventId = currentEventId {
            eventId = currentEventId
        }
        else {
            eventId = ""
        }
        return eventId
    }
    
    static func getCurrentEventName() -> String {
        var eventName:String
        let defaults = UserDefaults.standard
        let currentEventName = defaults.string(forKey: DEFAULT_CURRENT_EVENT_NAME)
        if let currentEventName = currentEventName {
            eventName = currentEventName
        }
        else {
            eventName = ""
        }
        return eventName
    }
    
    static func getCurrentEvent() -> EAEvent {
        let id = EAEvent.getCurrentEventId()
        let name = EAEvent.getCurrentEventName()
        let current = EAEvent(id: id,eventName: name)
        return current
    }
    
    static func didSwitchEvent(_ event:EAEvent?) {
        var name:String = ""
        var id:String = ""
        let defaults = UserDefaults.standard
        
        if let event = event {
            if let eventName = event.name {
                name = eventName
            }
            if let eventId = event.id {
                id = eventId
            }
        }
        
        defaults.set(id, forKey: DEFAULT_CURRENT_EVENT_ID)
        defaults.set(name, forKey: DEFAULT_CURRENT_EVENT_NAME)
    }
}
