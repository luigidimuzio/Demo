//
//  ServiceCategory+Realm.swift
//  DryveApp
//
//  Created by Luigi Di Muzio on 07/02/17.
//  Copyright © 2017 Dryve Inc. All rights reserved.
//

import RealmSwift

/*
extension ServiceCategory: Persistable {
    init(realmObject: RealmServiceCategory) {
        additionalInformation = realmObject.additionalInformation
        imageId = realmObject.imageId
        type = realmObject.type
        name = realmObject.name
        order = realmObject.order
        parseId = realmObject.parseId
        providerId = realmObject.providerId
        services = realmObject.services.map { ServiceDetail(realmObject: $0) }
    }
    
    func toRealmObject() -> RealmServiceCategory {
        let realmObject = RealmServiceCategory()
        realmObject.additionalInformation = additionalInformation
        realmObject.imageId = imageId
        realmObject.type = type
        realmObject.name = name
        realmObject.order = order
        realmObject.parseId = parseId
        realmObject.providerId = providerId
        realmObject.services.append(objectsIn: services.map { $0.toRealmObject() } )
        return realmObject
    }
}
*/
