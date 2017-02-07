//
//  RealmTimeRange.swift
//  DryveApp
//
//  Created by Luigi Di Muzio on 03/02/17.
//  Copyright © 2017 Dryve Inc. All rights reserved.
//

import RealmSwift

class RealmTimeRange: Object {
    dynamic var start = Date()
    dynamic var end = Date()
}
