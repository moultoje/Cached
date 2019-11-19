//
//  Waypoint.swift
//  Cached
//
//  Created by Katie Rievley on 11/17/19.
//  Copyright © 2019 Mobile Treasure Hunt. All rights reserved.
//

import Foundation
import UIKit

struct Waypoint {
    var clue: String
    var latitude: Double
    var longitude: Double
    var id: String?
    
    var dictionary:[String:Any]{
        return [
            "clue": clue,
            "latitude": latitude,
            "longitude": longitude
        ]
    }
}

extension Waypoint {
    init(dictionary: [String:Any], id: String) {
        clue = dictionary["clue"] as? String ?? ""
        latitude = dictionary["latitude"] as? Double ?? 0
        longitude = dictionary["longitude"] as? Double ?? 0
        
        /*
         self.init(name: name, isPrivate: isPrivate, creator: creator, description: description, generalLocation: generalLocation, numberWaypoints: numberWaypoints, listWaypoints: listWaypoints, id: id)
         */
    }
}
