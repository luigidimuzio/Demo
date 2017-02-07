//
//  Request.swift
//  Carcierge
//
//  Created by Mattia Bugossi on 23/07/15.
//  Copyright (c) 2015 Carcierge Technology. All rights reserved.
//

import Parse

typealias CompletionHandlerForRequestCreation = ((Bool, NSError?) -> ())?

struct Request {
    
    //external ids
    var parseId: String?
    var bringgId: String?
    var backendId: String?
    var stripeChargeId: String?

    //TODO: this probably can be moved in a 'TrackableOrder' struct or similar
    var bringgSharedUuid: String?
    var bringgUuid: String?
    var alreadyHeadedToYou = false

    //coupon
    var couponDiscount: NSNumber?
    var couponFromUserParseId: String?
    var couponHasToRegenerate = false
    var couponParseId: String?
    var couponTitle: String?
    
    //TODO: move all this info in a driver object
    var driverAvatarURL: URL?
    var driverBringgId: String?
    var driverLocation: CLLocation?
    var driverName: String?
    var driverPhoneNumber: String?
    
    //pickup-dropoff
    var pickUpPlace: Place?
    var dropOffPlace: Place?
//    var waypoints: [GeoPoint]?

    fileprivate(set) var status: String?
    var customerId: String?
    var serviceCategories: [ServiceCategory] = []
    var zoneId: String?
    var zone: Zone?
    var totalCharge: Double?
    var gasGallons: NSNumber?
    var pickUpInformation: String?
    var timeRangeScheduled: TimeRange?
    var timeRangeForCustomer: TimeRange?
    var estimatedDropOffTime: Date?

    var orderType: OrderType = .unknown

    enum Status: String {
        case Created = "created"
        case Accepted = "accepted"
        case OnTheWay = "on_the_way"
        case CheckedIn = "checked_in"
        case Canceled = "canceled"
        case InReview = "in_review"
        case Done = "done"
        case Unknown = "unknown"
    }
    
    enum OrderType: String {
        case unknown = "Unknown"
        case AB = "AB"
        case carServices = "CarServices"
    }
        
    var currentStatus: Status {
        get {
            let statusTypeOrNil = status != nil ? Status(rawValue: status!) : nil
            return statusTypeOrNil ?? .Unknown
        }
        set {
            status = newValue.rawValue
        }
    }
    
    mutating func setStatusbyCode(_ status: Int) -> Status {
        switch status {
        case 0: currentStatus = .Created
        case 6: currentStatus = .Accepted
        case 2: currentStatus = .OnTheWay
        case 3: currentStatus = .CheckedIn
        case 4: currentStatus = .Done
        case 7: currentStatus = .Canceled
        default: currentStatus = .Unknown
        }
        return currentStatus
    }
    
    mutating func addService(_ service: ServiceDetail, category: ServiceCategory) {
        if let index = serviceCategories.index(of: category) {
            var categoryToUpdate = serviceCategories[index]
            categoryToUpdate.addService(service)
            serviceCategories[index] = categoryToUpdate
        } else {
            //TODO: update servicecategory initializers to provide copies in functional way
            var categoryToAdd = category
            categoryToAdd.updateWithServices(services: [service])
            serviceCategories.append(categoryToAdd)
        }
    }
    
    mutating func removeService(_ service: ServiceDetail, category: ServiceCategory) {
        if let index = serviceCategories.index(of: category) {
            var categoryToUpdate = serviceCategories[index]
            if categoryToUpdate.services.count > 1 {
                categoryToUpdate.removeService(service)
                serviceCategories[index] = categoryToUpdate
            } else {
                serviceCategories.remove(at: index)
            }
            
        }
    }
    
    var services: [ServiceDetail] {
        get {
            var results: [ServiceDetail] = []
            for category in serviceCategories {
                results.append(contentsOf: category.services)
            }
            return results
        }
    }
    
    var serviceSelections:[(ServiceCategory, ServiceDetail)] {
        get {
            var results: [(ServiceCategory, ServiceDetail)] = []
            for category in serviceCategories {
                for service in category.services {
                    results.append((category, service))
                }
            }
            return results
        }
    }
    
    var isOrderWithGas: Bool {
        var thereIsUnitaryCostService = false
        for service in services {
            if service.isUnitaryPrice == true {
                thereIsUnitaryCostService = true
            }
        }
        
        return thereIsUnitaryCostService
    }
    
    var totalFee: Double {
        var fuelFee = 0.0
        let fuelIsPresent = services.filter({ $0.isUnitaryPrice }).count > 0
        if fuelIsPresent && services.count > 1 {
            fuelFee = 3.99
        } else if fuelIsPresent {
            fuelFee = 7.99
        }
        return services.map({ $0.fee }).reduce(fuelFee, +)
    }
    
    var currentAmount: Double {
        var partialAmount = 0.0
        for service in services {
            if service.isUnitaryPrice == false {
                partialAmount += service.cost
            }
        }
        partialAmount += totalFee
        if let couponDiscount = couponDiscount , couponDiscount.doubleValue > 0 {
            partialAmount = max(0.0, partialAmount - couponDiscount.doubleValue)
        }
        return partialAmount
    }
    
    var partialAmount: Double {
        var amount = 0.0
        for service in services where service.isUnitaryPrice == false {
                amount += service.cost
        }
        return amount
    }
    
    func partialAmountString(_ considerCoupon: Bool = false) -> String {
        var unitaryCost = 0.0
        var additionalPriceString = ""
        
        for category in serviceCategories {
            for service in category.services where service.isUnitaryPrice == true {
                unitaryCost = service.cost
                additionalPriceString = " + \(category.unitaryCostsString)"
            }
        }
        
        if partialAmount == 0 && unitaryCost > 0 {
            return "$ " + String(format: "%.2f", unitaryCost) + "/gal"
        } else {
            return "$ " + String(format: "%.02f", partialAmount) + additionalPriceString
        }
    }
    
    func totalAmountString(_ considerCoupon: Bool = false) -> String {
        var unitaryCostsString = ""
        
        for category in serviceCategories {
            for service in category.services where service.isUnitaryPrice == true {
                let costsString = category.unitaryCostsString
                unitaryCostsString = " + \(costsString)"

            }
        }
        return "$ " + String(format: "%.02f", currentAmount) + unitaryCostsString
    }
}

extension Request {
    init?(parseObject object: PFObject) {
        bringgId = object.value(forKey: "bringgId") as? String
        backendId = object.value(forKey: "backendId") as? String

        couponDiscount = object.value(forKey: "couponDiscount") as? NSNumber
        couponFromUserParseId = object.value(forKey: "couponFromUserParseId") as? String
        couponTitle = object.value(forKey: "couponTitle") as? String
//        gasGallons: NSNumber?
        parseId = object.objectId

        stripeChargeId = object.value(forKey: "chargeId") as? String
        totalCharge = object.value(forKey: "totalCharge") as? Double

        if let cartJSONString = object.value(forKey: "cart") as? String {
            serviceCategories = decodeCartJSON(cartJSONString) ?? []
        }

        pickUpInformation = object.value(forKey: "pickUpInformation") as? String
        
        if let orderTypeString = object.value(forKey: "orderType") as? String {
            orderType = OrderType(rawValue: orderTypeString) ?? .unknown
        }

        if let pickUpPoint = object.value(forKey: "pickUpLocation") as? PFGeoPoint,
            let pickUpAddress = object.value(forKey: "pickUpAddress") as? String
        {
            let coordinate = GeoPoint(latitude: pickUpPoint.latitude, longitude: pickUpPoint.longitude)
            pickUpPlace = Place(address: pickUpAddress, location: coordinate)
        }
        
        if  let waypoints = object.value(forKey: "waypoints") as? [PFGeoPoint],
            let dropOffPoint = waypoints.last,
            let dropOffAddress = object.value(forKey: "dropOffAddress") as? String
        {
            let coordinate = GeoPoint(latitude: dropOffPoint.latitude, longitude: dropOffPoint.longitude)
            dropOffPlace = Place(address: dropOffAddress, location: coordinate)
        }
        
        status = object.value(forKey: "status") as? String
        
        //Scheduled slot time range
        if let customerTimeStart = object.value(forKey: "customerSlotStart") as? Date,
            let customerTimeEnd = object.value(forKey: "customerSlotEnd") as? Date {
            timeRangeForCustomer = TimeRange(start: customerTimeStart, end: customerTimeEnd)
        }
        
        //Time range to show to customer
        if let scheduledTimeStart = object.value(forKey: "scheduledSlotStart") as? Date,
            let scheduledTimeEnd = object.value(forKey: "scheduledSlotEnd") as? Date {
            timeRangeScheduled = TimeRange(start: scheduledTimeStart, end: scheduledTimeEnd)
        }
        
        estimatedDropOffTime = object.value(forKey: "estimatedDropOffTime") as? Date

//        zoneId: String?
    }
    
    func decodeCartJSON(_ jsonString: String) -> [ServiceCategory]? {
        if let data = jsonString.data(using: String.Encoding.utf8) {
            do {
                guard let cartJSONArray = try JSONSerialization.jsonObject(with: data, options: []) as? [[String:AnyObject]] else {
                    return nil
                }
                var results: [ServiceCategory] = []
                for json in cartJSONArray {
                    if let serviceCategory = ServiceCategory(JSON: json) {
                        results.append(serviceCategory)
                    }
                }
                return results
            } catch {
                return nil
            }
        }
        return nil
    }
    
    func toParseObject() -> PFObject {
        
        var service: PFObject
        if let parseId = parseId {
            service = PFObject(withoutDataWithClassName: "Requests", objectId: parseId)
        }
        else {
            service = PFObject(className: "Requests")
        }
        setObject(service, withOptionalValue: stripeChargeId, forKey: "chargeId")
        setObject(service, withOptionalValue: currentAmount, forKey: "partialCharge")
        setObject(service, withOptionalValue: bringgId, forKey: "bringgId")
        setObject(service, withOptionalValue: backendId, forKey: "backendId")
        setObject(service, withOptionalValue: status, forKey: "status")
        setObject(service, withOptionalValue: serviceCategories.toJSONString(), forKey: "cart")
        
        setObject(service, withOptionalValue: couponDiscount, forKey: "couponDiscount")
        setObject(service, withOptionalValue: couponTitle, forKey: "couponTitle")
        setObject(service, withOptionalValue: couponFromUserParseId, forKey: "couponFromUser")

        setObject(service, withOptionalValue: timeRangeScheduled?.start, forKey: "scheduledSlotStart")
        setObject(service, withOptionalValue: timeRangeScheduled?.end, forKey: "scheduledSlotEnd")
        setObject(service, withOptionalValue: timeRangeForCustomer?.start, forKey: "customerSlotStart")
        setObject(service, withOptionalValue: timeRangeForCustomer?.end, forKey: "customerSlotEnd")

        setObject(service, withOptionalValue: estimatedDropOffTime, forKey: "estimatedDropOffTime")

        setObject(service, withOptionalValue: orderType.rawValue, forKey: "orderType")

        if let pickUpLocation = pickUpPlace?.location {
            let geoPoint = PFGeoPoint(latitude: pickUpLocation.latitude, longitude: pickUpLocation.longitude)
            service.setValue(geoPoint, forKey: "pickUpLocation")
        }
        if let pickUpAddress = pickUpPlace?.address {
            service.setValue(pickUpAddress, forKey: "pickUpAddress")
        }
        
        if let dropOffLocation = dropOffPlace?.location {
            let geoPoint = PFGeoPoint(latitude: dropOffLocation.latitude, longitude: dropOffLocation.longitude)
            service.setValue([geoPoint], forKey: "waypoints")
        }
        if let dropOffAddress = dropOffPlace?.address {
            service.setValue(dropOffAddress, forKey: "dropOffAddress")
        }
        
        setObject(service, withOptionalValue: pickUpInformation, forKey: "pickUpInformation")
        for category in serviceCategories {
            if let serviceType = category.services.first {
                print("\(category.name): \(serviceType.name)")
                if category.name == "Fuel Up" {
                    service.setValue(serviceType.name, forKey: "fuelType")
                } else if category.name == "Car Wash" {
                    service.setValue(serviceType.name, forKey: "carWashType")
                } else if category.name == "Oil Change" {
                    service.setValue(serviceType.name, forKey: "oilType")
                }
            }
        }
        return service
    }
    
    func setObject(_ object: PFObject, withOptionalValue value: Any?, forKey key: String) {
        guard value != nil else { return }
        object.setValue(value, forKey: key)
    }
}
