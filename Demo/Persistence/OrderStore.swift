//
//  OrderStore.swift
//  DryveApp
//
//  Created by Luigi Di Muzio on 02/02/17.
//  Copyright © 2017 Dryve Inc. All rights reserved.
//


import RealmSwift

protocol Persistable {
    
    associatedtype RealmObject: Object
    
    init(realmObject: RealmObject)
    func toRealmObject() -> RealmObject
}

class Store<T: Persistable> {
    
    private let realm: Realm
    
    public convenience init() throws {
        try self.init(realm: Realm())
    }
    
    internal init(realm: Realm) {
        self.realm = realm
    }
}










