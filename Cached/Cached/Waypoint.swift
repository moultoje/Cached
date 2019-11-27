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
    var name: String
    var clue: String
    var latitude: Double
    var longitude: Double
    var radius: Int
    var id: String
    
    var dictionary:[String:Any]{
        return [
            "name": name,
            "clue": clue,
            "latitude": latitude,
            "longitude": longitude,
            "radius": radius
        ]
    }
}

extension Waypoint {
    init(dictionary: [String:Any], id: String) {
        name = dictionary["name"] as? String ?? ""
        clue = dictionary["clue"] as? String ?? ""
        latitude = dictionary["latitude"] as? Double ?? 0
        longitude = dictionary["longitude"] as? Double ?? 0
        radius = dictionary["radius"] as? Int ?? 0
        self.id = id
        
        /*
         self.init(name: name, isPrivate: isPrivate, creator: creator, description: description, generalLocation: generalLocation, numberWaypoints: numberWaypoints, listWaypoints: listWaypoints, id: id)
         */
    }
}
