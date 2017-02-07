//
//  Zone.swift
//  Carcierge
//
//  Created by Mattia Bugossi on 23/07/15.
//  Copyright (c) 2015 Carcierge Technology. All rights reserved.
//

//import CoreData
import Parse
import MapKit


struct Zone {
    
    var coordinates: [GeoPoint]
    var latitudePoints: NSArray?
    var longitudePoints: NSArray?
    var minutesPerSlot: NSNumber?
    var parseId: String
    var closingDays: NSArray?
    var openingHour: NSNumber?
    var closingHour: NSNumber?
    var isVisibleOnMap: Bool
    var zipCodes: [String] = []
    
    var polygon: MKPolygon {
        get {
            var cl_coordinates = coordinates.map { CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude) }
            return MKPolygon(coordinates: &cl_coordinates, count: cl_coordinates.count)
        }
    }

}

extension Zone {
    
    init?(parseObject: PFObject) {
        guard
            let longitudePoints = parseObject["pointsLongitude"] as? [Double],
            let latitudePoints = parseObject["pointsLatitude"] as? [Double] ,
            parseObject.objectId != nil
            else {
                return nil
        }
        
        parseId = parseObject.objectId!
        minutesPerSlot = parseObject["slotMinutes"] as? Int as NSNumber?
        zipCodes = parseObject["zipcodes"] as? [String] ?? []
        openingHour = parseObject["openingHour"] as? Int as NSNumber?
        closingHour = parseObject["closingHour"] as? Int as NSNumber?
        isVisibleOnMap = parseObject["isVisibleOnTheMap"] as? Bool ?? false
        
        var objectCoordinates: [GeoPoint] = []
        for index in 0 ..< latitudePoints.count {
            objectCoordinates.append(GeoPoint(latitude: latitudePoints[index], longitude: longitudePoints[index]))
        }
        coordinates = objectCoordinates
    }
    
}
