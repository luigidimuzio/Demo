//
//  ServiceCategory.swift
//  Carcierge
//
//  Created by Mattia Bugossi on 23/07/15.
//  Copyright (c) 2015 Carcierge Technology. All rights reserved.
//

import CoreData
import Parse
import ObjectMapper

struct ServiceCategory {

    //TODO: check initialization/data integrity-consistence
    //every required value should be  provided at initialization, not as default
    var additionalInformation: String?
    var imageId: String?
    var type: String?
    var name: String = ""
    var order: NSNumber?
    var parseId: String = ""
    var providerId: String?
    var services: [ServiceDetail] = []
    
    var image: UIImage {
        get {
            if imageId == "1" {
                return UIImage(named: "ServicesIconCarWash")!
            } else if imageId == "2" {
                return UIImage(named: "ServicesIconOilChange")!
            } else if imageId == "3" {
                return UIImage(named: "ServicesIconFuelUp")!
            } else if imageId == "4" {
                return UIImage(named: "ServicesIconAtoB")!
            }

            return UIImage(named:"gears 2")!
        }
    }

    var color: UIColor {
        get {
            if imageId == "1" {
                return UIColor(red: 22/255.0, green: 135/255.0, blue: 2/255.0, alpha: 1)
            } else if imageId == "2" {
                return UIColor(red: 51/255.0, green: 189/255.0, blue: 34/255.0, alpha: 1)
            } else if imageId == "3" {
                return UIColor(red: 26/255.0, green: 163/255.0, blue: 16/255.0, alpha: 1)
            }

            return UIColor(red: 86/255.0, green: 198/255.0, blue: 38/255.0, alpha: 1)
        }
    }

    var unitaryCostsString: String {
        get {
            if name == "Fuel Up" {
                return "Fuel"
            }

            return ""
        }
    }
    
    mutating func updateWithServices(services newServices: [ServiceDetail]) {
        services = newServices
    }
    
    mutating func addService(_ service: ServiceDetail) {
        if !services.contains(service) {
            services.append(service)
        }
    }
    
    mutating func removeService(_ service: ServiceDetail) {
        if let index = services.index(of: service) {
            services.remove(at: index)
        }
    }
}

extension ServiceCategory {
    init?(parseObject object: PFObject) {
        guard let objectId = object.objectId else { return nil }
        parseId = objectId
        name = object.value(forKey: "name") as? String ?? ""
        providerId = object.value(forKey: "providerId") as? String
        imageId = object.value(forKey: "imageId") as? String
        additionalInformation = object.value(forKey: "additionalInformation") as? String
        order = object.value(forKey: "order") as? NSNumber
        type = object.value(forKey: "type") as? String
    }
}

extension ServiceCategory: Mappable {
    init?(map: Map) {
    
    }
    
    mutating func mapping(map: Map) {
        additionalInformation   <- map["additionalInformation"]
        imageId                 <- map["imageId"]
        type                    <- map["type"]
        name                    <- map["name"]
        order                   <- map["order"]
        parseId                 <- map["parseId"]
        providerId              <- map["providerId"]
        services                <- map["services"]
    }
}

extension ServiceCategory: Equatable {}

func ==(lhs: ServiceCategory, rhs: ServiceCategory) -> Bool {
    return lhs.parseId == rhs.parseId
}
