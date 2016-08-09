//
//  Event.swift
//  EventsApp
//
//  Created by Keith Caffrey on 14/07/2016.
//  Copyright © 2016 KC. All rights reserved.
//

import Foundation


public class EAEvent:NSObject{
    var name:String?
    var id:String?
    
    init(id:String?,eventName:String) {
        self.id = id
        self.name = eventName;
    }
}
