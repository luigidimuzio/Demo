//
//  Place.swift
//  DryveApp
//
//  Created by Luigi Di Muzio on 03/02/17.
//  Copyright © 2017 Dryve Inc. All rights reserved.
//

import ObjectMapper


struct Place {
    
    var name: String?
    var address: String?
    var location: GeoPoint?
    
    init(name aName: String? = nil, address anAddress: String? = nil, location aLocation: GeoPoint? = nil) {
        name = aName
        address = anAddress
        location = aLocation
    }
}


extension Place: Mappable {

    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        address     <- map["address"]
        location    <- map["location"]
    }
}
