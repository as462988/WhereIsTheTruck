//
//  FirebaseManager.swift
//  RunRunTruck
//
//  Created by yueh on 2019/8/28.
//  Copyright © 2019 yueh. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseStorage

class FirebaseManager {
    
    static let shared = FirebaseManager()
    var truckData: [TruckData] = []
    
    let db = Firestore.firestore()
    
    let storage = Storage.storage()
    
    //讀取 truckData
    
    func getTruckData(completion: @escaping ([TruckData]?) -> Void ) {
        db.collection(Truck.truck.rawValue).getDocuments { (snapshot, error)  in
            guard let snapshot = snapshot else {
                completion(nil)
                return
            }
            
            for document in snapshot.documents {
                
                guard let name = document.data()[Truck.name.rawValue] as? String,
                    let logoImage = document.data()[Truck.logoImage.rawValue] as? String,
                let openTimestamp = document.data()[Truck.openTime.rawValue] as? Timestamp,
                let closeTimestamp = document.data()[Truck.closeTime.rawValue] as? Timestamp else {return}
             
                let truck = TruckData(document.documentID, name, logoImage, openTimestamp, closeTimestamp)
                
                self.truckData.append(truck)

            }
            completion(self.truckData)
        }
        
    }
    
}
