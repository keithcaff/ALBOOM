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
            name = event.name!
            id = event.id!
        }
        defaults.set(id, forKey: DEFAULT_CURRENT_EVENT_ID)
        defaults.set(name, forKey: DEFAULT_CURRENT_EVENT_NAME)
    }
}
