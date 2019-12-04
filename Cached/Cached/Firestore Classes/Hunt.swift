//
//  Hunt.swift
//  Cached
//
//  Created by Katie Rievley on 11/10/19.
//  Copyright © 2019 Mobile Treasure Hunt. All rights reserved.
//

import Foundation
import UIKit

struct Hunt {
    var name: String
    var isPrivate: Bool
    var creator: String
    var description: String
    var generalLocation: String
    var numberWaypoints: Int
    var listWaypoints: [String]
    var id: String?
    
    var dictionary:[String:Any]{
        return [
            "name": name,
            "isPrivate": isPrivate,
            "creator": creator,
            "description": description,
            "generalLocation": generalLocation,
            "numberWaypoints": numberWaypoints,
            "listWaypoints": listWaypoints
        ]
    }
}

extension Hunt {
    init(dictionary: [String:Any], id: String) {
            name = dictionary["name"] as? String ?? ""
            isPrivate = dictionary["isPrivate"] as? Bool ?? false
            creator = dictionary["creator"] as? String ?? ""
            description = dictionary["description"] as? String ?? ""
            generalLocation = dictionary["generalLocation"] as? String ?? ""
            numberWaypoints = dictionary["numberWaypoints"] as? Int ?? 0
            listWaypoints = dictionary["listWaypoints"] as? [String] ?? []
    }
}
