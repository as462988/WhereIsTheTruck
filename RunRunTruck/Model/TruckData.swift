//
//  TruckData.swift
//  RunRunTruck
//
//  Created by yueh on 2019/8/28.
//  Copyright © 2019 yueh. All rights reserved.
//

import Foundation
import Firebase

enum Truck: String {
    
    case truck = "Truck"
    
    case truckId
    
    case name
    
    case open
    
    case logoImage
    
    case story
    
    case openTime
    
    case location
    
    case chatRoom
    
}

struct TruckData {
    
    var id: String
    
    let name: String
    
    let logoImage: String
    
    let open: Bool
    
    let story: String
    
    let openTime: Double?
    
    let location: GeoPoint?
    
    var address: String = ""
    
    init(_ id: String, _ name: String, _ logoImage: String, _ story: String, _ open: Bool,
         _ openTime: Double?, _ location: GeoPoint?) {
        self.id = id
        self.name = name
        self.logoImage = logoImage
        self.open = open
        self.story = story
        self.openTime = openTime
        self.location = location
    }
}

struct Message {
    
    var uid: String
    var name: String
    var text: String
    var createTime: Double
    
    init(_ uid: String, _ name: String, _ text: String, _ createTime: Double) {
        self.uid = uid
        self.name = name
        self.text = text
        self.createTime = createTime
    }
}

enum User: String {
    
    case user = "User"
    
    case uid
    
    case name
    
    case email
    
    case text
    
    case createTime
}

struct UserData {
    
    let name: String
    
    let email: String
    
    let truckId: String?
    
    init(name: String, email: String, truckId: String?) {
        self.name = name
        self.email = email
        self.truckId = truckId
    }
}

enum Boss: String {
    
    case boss = "Boss"
    
    case uid
    
    case name
    
    case email
}
