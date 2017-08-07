//
//  Event.swift
//  EventsApp
//
//  Created by Keith Caffrey on 14/07/2016.
//  Copyright © 2016 KC. All rights reserved.
//

import Foundation


open class EAEvent:NSObject{
    var name:String?
    var id:String?
    
    init(id:String?,eventName:String) {
        self.id = id
        self.name = eventName;
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
