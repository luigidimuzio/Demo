//
//  RealmPlace.swift
//  DryveApp
//
//  Created by Luigi Di Muzio on 03/02/17.
//  Copyright © 2017 Dryve Inc. All rights reserved.
//

import RealmSwift

class RealmPlace: Object {
    dynamic var name: String? = nil
    dynamic var address: String? = nil
    dynamic var location: RealmGeoPoint?
}
