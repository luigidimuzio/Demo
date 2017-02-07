//
//  RealmServiceCategory.swift
//  DryveApp
//
//  Created by Luigi Di Muzio on 03/02/17.
//  Copyright © 2017 Dryve Inc. All rights reserved.
//

import RealmSwift

class RealmServiceCategory: Object {
    dynamic var additionalInformation: String? = nil
    dynamic var imageId: String? = nil
    dynamic var type: String?
    dynamic var name: String = ""
    dynamic var order: NSNumber? = nil
    dynamic var parseId: String = ""
    dynamic var providerId: String? = nil
    let services = List<RealmServiceDetail>()
}
