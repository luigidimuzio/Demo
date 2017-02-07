//
//  RealmService.swift
//  DryveApp
//
//  Created by Luigi Di Muzio on 03/02/17.
//  Copyright © 2017 Dryve Inc. All rights reserved.
//

import RealmSwift

class RealmServiceDetail: Object {
    dynamic var address: String? = nil
    let basePrice = RealmOptional<Double>()
    dynamic var caption: String? = nil
    dynamic var carSizeDependent = false
    let carSizeExtra = RealmOptional<Double>()
    dynamic var eta: String? = nil
    dynamic var isUnitaryPrice = false
    dynamic var name = ""
    dynamic var parseId: String? = nil
    let unitPrice = RealmOptional<Double>()
    dynamic var nameForBackend: String? = nil
    let deliveryFee = RealmOptional<Double>()
}
