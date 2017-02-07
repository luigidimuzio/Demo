//
//  ServiceDetail+Realm.swift
//  DryveApp
//
//  Created by Luigi Di Muzio on 07/02/17.
//  Copyright © 2017 Dryve Inc. All rights reserved.
//


extension ServiceDetail: Persistable {
    init(realmObject: RealmServiceDetail) {
        address = realmObject.address
        if let basePriceValue = realmObject.basePrice.value {
            basePrice = NSNumber(value: basePriceValue)
        } else {
            basePrice = nil
        }
        caption = realmObject.caption
        carSizeDependent = realmObject.carSizeDependent
        if let carSizeExtraValue = realmObject.carSizeExtra.value {
            carSizeExtra = NSNumber(value: carSizeExtraValue)
        } else {
            carSizeExtra = nil
        }
        eta = realmObject.eta
        isUnitaryPrice = realmObject.isUnitaryPrice
        name = realmObject.name
        parseId = realmObject.parseId
        if let unitPriceValue = realmObject.unitPrice.value {
            unitPrice = NSNumber(value: unitPriceValue)
        } else {
            unitPrice = nil
        }
        nameForBackend = realmObject.nameForBackend
        deliveryFee = realmObject.deliveryFee.value
    }
    
    func toRealmObject() -> RealmServiceDetail {
        let realmObject = RealmServiceDetail()
        realmObject.address = address
        realmObject.basePrice.value = basePrice?.doubleValue
        realmObject.caption = caption
        realmObject.carSizeDependent = carSizeDependent
        realmObject.carSizeExtra.value = carSizeExtra?.doubleValue
        realmObject.eta = eta
        realmObject.isUnitaryPrice = isUnitaryPrice
        realmObject.name = name
        realmObject.parseId = parseId
        realmObject.unitPrice.value = unitPrice?.doubleValue
        realmObject.nameForBackend = nameForBackend
        realmObject.deliveryFee.value = deliveryFee
        return realmObject
    }
}
