 //
//  ServiceCategory.swift
//  Carcierge
//
//  Created by Mattia Bugossi on 23/07/15.
//  Copyright (c) 2015 Carcierge Technology. All rights reserved.
//

import CoreData
import Parse
import MapKit
import ObjectMapper

struct ServiceDetail {
    
    var address: String?
    var basePrice: NSNumber?
    var caption: String?
    var carSizeDependent = false
    var carSizeExtra: NSNumber?
    var eta: String?
    var isUnitaryPrice = false
    var name: String = ""
    var parseId: String?
    var unitPrice: NSNumber?
    var nameForBackend: String?
    var deliveryFee: Double?
    
    var cost: Double {
        let cost = basePrice?.doubleValue ?? 0.0
        if carSizeDependent && unitPrice != nil {
            let currentUserCar = User.currentUser()!.cars.allObjects.first as! Car
            let currentUserCarEngineOilQuarters = currentUserCar.engineOilQuarters?.doubleValue ?? 0.0
            return cost + (currentUserCarEngineOilQuarters - 5) * (unitPrice?.doubleValue ?? 0.0)
        } else if let carSizeExtra = carSizeExtra , carSizeDependent && User.currentUser()!.requiresCarSizeExtra {
            return cost + carSizeExtra.doubleValue
        } else if isUnitaryPrice {
            return unitPrice?.doubleValue ?? 0.0
        } else {
            return cost
        }
    }
    
    var fee: Double {
        return deliveryFee ?? 0.0
    }
    
}
 
extension ServiceDetail: Mappable {
    init?(map: Map) {
        
    }

    mutating func mapping(map: Map) {
        address             <- map["address"]
        basePrice           <- map["basePrice"]
        caption             <- map["caption"]
        carSizeDependent    <- map["carSizeDependent"]
        carSizeExtra        <- map["carSizeExtra"]
        eta                 <- map["eta"]
        isUnitaryPrice      <- map["isUnitaryPrice"]
        name                <- map["name"]
        parseId             <- map["parseId"]
        unitPrice           <- map["unitPrice"]
        nameForBackend      <- map["nameForBackend"]
        deliveryFee         <- map["deliveryFee"]

    }
}
 
extension ServiceDetail {
    
    init?(serviceObject object: PFObject) {
        parseId = object.objectId
        basePrice = object.value(forKey: "price") as? Double as NSNumber?
        caption = object.value(forKey: "serviceDescription") as? String
        carSizeDependent = object.value(forKey: "carSizeDependent") as? Bool ?? false
        carSizeExtra = object.value(forKey: "carSizeExtra") as? Double as NSNumber?
        eta = object.value(forKey: "eta") as? String
        isUnitaryPrice = object.value(forKey: "isUnitaryPrice") as? Bool ?? false
        name = object.value(forKey: "name") as? String ?? ""
        nameForBackend = object.value(forKey: "nameForBackend") as? String
        unitPrice = object.value(forKey: "unitPrice") as? Double as NSNumber?
        deliveryFee = object.value(forKey: "deliveryFee") as? Double

    }
    
    init?(gasServiceObject gasService: PFObject) {
        isUnitaryPrice = true
        unitPrice = gasService.value(forKey: "maxPrice") as! Double as NSNumber?
        address = gasService.value(forKey: "minPriceAddress") as? String
        parseId = gasService.value(forKey: "objectId") as? String
        caption = gasService.value(forKey: "serviceDescription") as? String
        eta = gasService.value(forKey: "eta") as? String

        let fuelType = gasService.value(forKey: "fuel") as? String
        if fuelType == "regular" {
            name = "87 Octane"
        } else if fuelType == "midgrade" {
            name = "89 Octane"
        } else if fuelType == "premium" {
            name = "91 Octane"
        } else {
            name = "Diesel"
        }
    }
    
    func toPFObject() -> PFObject {
        return PFObject()
    }
}

extension ServiceDetail: Equatable {}

func ==(lhs: ServiceDetail, rhs: ServiceDetail) -> Bool {
    return lhs.parseId == rhs.parseId
}
