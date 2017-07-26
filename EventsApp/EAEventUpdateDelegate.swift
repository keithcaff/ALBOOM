//
//  EAEventUpdateDelegate.swift
//  EventsApp
//
//  Created by Keith Caffrey on 09/08/2016.
//  Copyright © 2016 KC. All rights reserved.
//

import Foundation

@objc protocol EAEventUpdateDelegate {
    
    func didSwitchEvent(_ event:EAEvent?);
}
