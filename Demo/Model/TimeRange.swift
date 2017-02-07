//
//  TimeRange.swift
//  DryveApp
//
//  Created by Luigi Di Muzio on 10/05/16.
//  Copyright © 2016 Dryve Inc. All rights reserved.
//

import Foundation
import ObjectMapper

public struct TimeRange {
    let start: Date
    let end: Date
    
    func overlapsTimeRange(_ anotherTimeRange: TimeRange) -> Bool {
        return start.timeIntervalSince1970 <= anotherTimeRange.end.timeIntervalSince1970
            && end.timeIntervalSince1970 >= anotherTimeRange.start.timeIntervalSince1970
    }
    
    func isInsideTimeRange(_ anotherTimeRange: TimeRange) -> Bool {
        return start.timeIntervalSince1970 >= anotherTimeRange.start.timeIntervalSince1970
            && end.timeIntervalSince1970 <= anotherTimeRange.end.timeIntervalSince1970
    }

    
    func firstTimeOverlappingTimeRange(_ timeRange: TimeRange) -> Date? {
        guard self.overlapsTimeRange(timeRange) else { return nil }
        if self.start.timeIntervalSince1970 < timeRange.start.timeIntervalSince1970 {
            return timeRange.start
        } else {
            return self.start
        }
    }
    
    var formattedString: String {
        let startDateFormatter = DateFormatter()
        startDateFormatter.dateFormat = "EEE, dd MMM HH:mm"
        let endDateFormatter = DateFormatter()
        endDateFormatter.dateFormat = "HH:mm"
        
        if !Date.is24HoursFormat_1 {
            startDateFormatter.dateFormat = "EEE, dd MMM hh:mm a"
            endDateFormatter.dateFormat = "hh:mm a"
        }
        return "\(startDateFormatter.string(from: start))-\(endDateFormatter.string(from: end))"

    }
}
