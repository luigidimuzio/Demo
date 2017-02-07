//
//  Place+Realm.swift
//  DryveApp
//
//  Created by Luigi Di Muzio on 07/02/17.
//  Copyright © 2017 Dryve Inc. All rights reserved.
//

import Foundation

extension Place: Persistable {
    init(realmObject: RealmPlace) {
        name = realmObject.name
        address = realmObject.address
        
        if let realmLocation = realmObject.location {
            location = GeoPoint(realmObject: realmLocation)
        } else {
            location = nil
        }
    }
    
    func toRealmObject() -> RealmPlace {
        let realmPlace = RealmPlace()
        realmPlace.address = address
        realmPlace.name = name
        realmPlace.location = location?.toRealmObject()
        return realmPlace
    }
}
