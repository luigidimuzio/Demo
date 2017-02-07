//
//  Request+Realm.swift
//  DryveApp
//
//  Created by Luigi Di Muzio on 07/02/17.
//  Copyright © 2017 Dryve Inc. All rights reserved.
//

import Foundation

/*
extension Request: Persistable {
    
    internal func toRealmObject() -> RealmOrder {
        let realmOrder = RealmOrder()
        return realmOrder
    }

    init(realmObject: RealmOrder) {
        parseId = realmObject.parseId
        bringgId = realmObject.bringgId
        backendId = realmObject.backendId
        stripeChargeId = realmObject.stripeChargeId
        
        bringgSharedUuid = realmObject.bringgSharedUuid
        bringgUuid = realmObject.bringgUuid
        
        couponDiscount = realmObject.couponDiscount
        couponFromUserParseId = realmObject.couponFromUserParseId
        couponHasToRegenerate = realmObject.couponHasToRegenerate
        couponParseId = realmObject.couponParseId
        couponTitle = realmObject.couponTitle
        
        driverAvatarURL = realmObject.driverAvatarURL
        driverBringgId = realmObject.driverBringgId
        driverLocation = realmObject.driverLocation
        driverName = realmObject.driverName
        driverPhoneNumber = realmObject.driverPhoneNumber
        
        if let realmPickUpPlace = realmObject.pickUpPlace {
            pickUpPlace = Place(realmObject: realmPickUpPlace)
        }
        
        if let realmDropOffPlace = realmObject.dropOffPlace {
            dropOffPlace = Place(realmObject: realmDropOffPlace)
        }
        
//        status =
        /*
        fileprivate(set) var status: String?

        var customerId: String?
        var serviceCategories: [ServiceCategory] = []

        */
        customerId = realmObject.customerId
//        serviceCategories = realmObject.serviceCategories.map { ServiceCategory(realmObject : $0) }
        
        zoneId = realmObject.zoneId
        totalCharge = realmObject.totalCharge.value
        gasGallons = realmObject.gasGallons
        pickUpInformation = realmObject.pickUpInformation
        
        if let realmTimeRange = realmObject.timeRangeScheduled {
            timeRangeScheduled = TimeRange(realmObject: realmTimeRange)
        }
        
        if let realmTimeRange = realmObject.timeRangeForCustomer {
            timeRangeForCustomer = TimeRange(realmObject: realmTimeRange)
        }
        
        estimatedDropOffTime = realmObject.estimatedDropOffTime
    }
}
*/
