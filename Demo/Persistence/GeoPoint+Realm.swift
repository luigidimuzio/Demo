//
//  GeoPoint+Realm.swift
//  DryveApp
//
//  Created by Luigi Di Muzio on 07/02/17.
//  Copyright © 2017 Dryve Inc. All rights reserved.
//

import Foundation

extension GeoPoint: Persistable {
    init(realmObject: RealmGeoPoint) {
        latitude = realmObject.latitude
        longitude = realmObject.longitude
    }
        
    func toRealmObject() -> RealmGeoPoint {
        let realmGeoPoint = RealmGeoPoint()
        realmGeoPoint.latitude = latitude
        realmGeoPoint.longitude = longitude
        return realmGeoPoint
    }
}
