//
//  DRVGeoPoint.swift
//  DryveApp
//
//  Created by Afnan Ahmad on 15/04/2016.
//  Copyright © 2016 Dryve Inc. All rights reserved.
//

import Foundation
import ObjectMapper

struct GeoPoint: Mappable {

    //MARK: - Properties
    var latitude: Double!
    var longitude: Double!

    //MARK: - Initializers
    init?(map: Map) {
        if map.JSON["lat"] == nil || map.JSON["lng"] == nil {
            return nil
        }
    }

    init(latitude: Double = 0, longitude: Double = 0) {
        self.latitude = latitude
        self.longitude = longitude
    }

    mutating func mapping(map: Map) {
        latitude <- map["lat"]
        longitude <- map["lng"]
    }

}
