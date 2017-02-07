//
//  TimeRange+Realm.swift
//  DryveApp
//
//  Created by Luigi Di Muzio on 07/02/17.
//  Copyright © 2017 Dryve Inc. All rights reserved.
//

import Foundation

extension TimeRange: Persistable {
    init(realmObject: RealmTimeRange) {
        start = realmObject.start
        end = realmObject.end
    }
    
    func toRealmObject() -> RealmTimeRange {
        let realmObject = RealmTimeRange()
        realmObject.start = start
        realmObject.end = end
        return realmObject
    }
}
