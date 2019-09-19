//
//  FirebaseManager.swift
//  RunRunTruck
//
//  Created by yueh on 2019/8/28.
//  Copyright © 2019 yueh. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

// swiftlint:disable type_body_length
// swiftlint:disable file_length
class FirebaseManager {
    
    static let shared = FirebaseManager()
    
    var openIngTruckData = [TruckData]()
    
    var currentUser: UserData?
    
    var bossTruck: TruckData?
    
    var message = [Message]()
    
    let db = Firestore.firestore()
    
    var truckID: String?
    
    var userID: String?
    
    var bossID: String?
    
    // MARK: About Truck
        //getAllTruck
    func getAllTruckDataForBadge(completion: @escaping ([TruckBadge]?) -> Void) {
        
        db.collection(Truck.truck.rawValue).addSnapshotListener { (snapshot, error) in
            
            var logoImageArr: [TruckBadge] = []
            
            if let err = error {
                print("Error getting documents: \(err)")
                completion(nil)
            } else {
                
                snapshot?.documentChanges.forEach({ (documentChange) in
                    let data = documentChange.document.data()
                    
                    guard let truckId = data[Truck.truckId.rawValue] as? String,
                        let name = data[Truck.name.rawValue] as? String,
                        let logoImage = data[Truck.logoImage.rawValue] as? String else {
                            
                            return
                    }
                    
                    if documentChange.type == .added {
                        
                        logoImageArr.append(TruckBadge(truckId: truckId, name: name, logoImage: logoImage))
                        
                    } else if documentChange.type == .removed {
                        print("remove")
                    }
                })
                completion(logoImageArr)
                
            }
        }
    }
//    
//    func getAllTruckData(completion: @escaping ([(TruckData, DocumentChangeType)]?) -> Void) {
//        
//        let order = db.collection(Truck.truck.rawValue).order(by: Truck.open.rawValue, descending: true)
//        
//        var allTruckData: [(TruckData, DocumentChangeType)] = []
//        
//        var openTimestamp: Double?
//        
//        var location: GeoPoint?
//        
//        order.addSnapshotListener { (snapshot, error) in
//            if let err = error {
//                print("Error getting documents: \(err)")
//                completion(nil)
//            } else {
//                
//                snapshot?.documentChanges.forEach({ (documentChange) in
//                    let data = documentChange.document.data()
//                    
//                    guard let name = data[Truck.name.rawValue] as? String,
//                        let logoImage = data[Truck.logoImage.rawValue] as? String,
//                        let open = data[Truck.open.rawValue] as? Bool,
//                        let story = data[Truck.story.rawValue] as? String else {return}
//                    
//                    openTimestamp = data[Truck.openTime.rawValue] as? Double
//                    
//                    location = data[Truck.location.rawValue] as? GeoPoint
//                    
//                    let truck = TruckData(documentChange.document.documentID,
//                                          name, logoImage, story, open,
//                                          openTimestamp, location)
//                    allTruckData.append((truck, documentChange.type))
//                })
//                completion(allTruckData)
//                
//            }
//        }
//    }
    
    func getOpeningTruckData(isOpen: Bool, completion: @escaping ([(TruckData, DocumentChangeType)]?) -> Void) {
        
        db.collection(Truck.truck.rawValue).whereField(
            Truck.open.rawValue, isEqualTo: isOpen).addSnapshotListener { (snapshot, error) in
                
                guard let snapshot = snapshot else {
                    print("Error fetching document: \(error!)")
                    return
                }
                
                var rtnTruckDatas: [(TruckData, DocumentChangeType)] = []
                snapshot.documentChanges.forEach({ (documentChange) in
                    let data = documentChange.document.data()
                    
                    guard let name = data[Truck.name.rawValue] as? String,
                        let logoImage = data[Truck.logoImage.rawValue] as? String,
                        let open = data[Truck.open.rawValue] as? Bool,
                        let story = data[Truck.story.rawValue] as? String,
                        let openTimestamp = data[Truck.openTime.rawValue] as? Double,
                        let location = data[Truck.location.rawValue] as? GeoPoint else {return}
                    
                    let truck = TruckData(documentChange.document.documentID,
                                          name, logoImage, story, open,
                                          openTimestamp, location)
                    rtnTruckDatas.append((truck, documentChange.type))
                })
                completion(rtnTruckDatas)
        }
        
    }
    
    func addTurck(name: String, img: String, story: String, completion: @escaping (String) -> Void) {
        
        let ref = db.collection(Truck.truck.rawValue).document()
        
        ref.setData([
            Truck.truckId.rawValue: ref.documentID,
            Truck.name.rawValue: name,
            Truck.logoImage.rawValue: img,
            Truck.story.rawValue: story,
            Truck.open.rawValue: false
        ]) { (error) in
            if let err = error {
                print("Error adding document: \(err)")
            }
        }
        
        completion(ref.documentID)
    }
    
    func changeOpenStatus(status: Bool, lat: Double? = nil, lon: Double? = nil) {
        
        guard let truckId = bossTruck?.id else { return }
        
        if status {
            let location = GeoPoint(latitude: lat!, longitude: lon!)
            
            db.collection(Truck.truck.rawValue).document(truckId).updateData([
                Truck.open.rawValue: status,
                Truck.openTime.rawValue: Date().timeIntervalSince1970,
                Truck.location.rawValue: location
            ]) { (error) in
                if let err = error {
                    print("Error modify: \(err)")
                } else {
                    print("Status modify Success")
                }
            }
        } else {
            
            db.collection(Truck.truck.rawValue).document(truckId).updateData([
                Truck.open.rawValue: status
            ]) { (error) in
                if let err = error {
                    print("Error modify: \(err)")
                } else {
                    print("Status modify Success")
                }
            }
        }
    }
    
    func updataStoryText(text: String) {
        
        guard let truckId = bossTruck?.id else { return }
        
        db.collection(Truck.truck.rawValue).document(truckId).updateData([
            Truck.story.rawValue: text
        ]) { (error) in
            if let err = error {
                print("Error modify: \(err)")
            } else {
                print("Status modify Success")
            }
        }
    }
    
    func getTruckId(truckName: String) {
        
        db.collection(Truck.truck.rawValue).whereField(
            Truck.name.rawValue,
            isEqualTo: truckName).getDocuments {[weak self] (snapshot, error) in
                
                guard error == nil else {
                    print("Error getting documents")
                    return
                }
                
                for document in snapshot!.documents {
                    self?.truckID = document.documentID
                    
                }
        }
        
    }

    // MARK: About User
    
    func getCurrentUserData(completion: @escaping (UserData?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        db.collection(User.user.rawValue).document(uid).addSnapshotListener { [weak self ] (snapshot, error) in
            
            guard let document = snapshot else {
                print("Error fetching document: \(error!)")
                completion(nil)
                return
            }
            guard let data = document.data() else {
                print("Document data was empty.")
                return
            }
            
            guard let name = data[User.name.rawValue] as? String,
                let email = data[User.email.rawValue] as? String,
                let badge = data[User.badge.rawValue] as? [String] else { return }
            
            if let image = data[User.image.rawValue] as? String {
            
            self?.currentUser = UserData(name: name, email: email, image: image, badge: badge)
            
            } else {
                
                self?.currentUser = UserData(name: name, email: email, badge: badge)
            }

            completion(self?.currentUser)
            print("Current data: \(data)")
        }
    }
    
    func setUserData(name: String, email: String) {
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        db.collection(User.user.rawValue).document(uid).setData([
            User.name.rawValue: name,
            User.email.rawValue: email,
            User.badge.rawValue: []
        ]) { error in
            
            if let error = error {
                print("Error adding document: \(error)")
            }
        }
    }
    
    func updataUserImage(image: String) {
        
        guard let uid = self.userID else {
            return
        }
        
        db.collection(User.user.rawValue).document(uid).updateData([
            User.image.rawValue: image
            ])
    }
    
    func addUserBadge(uid: String, truckId: String) {
        
        db.collection(User.user.rawValue).document(uid).updateData([
            
            User.badge.rawValue: FieldValue.arrayUnion([truckId])
        ]) { error in
            
            if let error = error {
                print("Error adding document: \(error)")
            }
        }
    }
    
    // MARK: About Boss
    func getCurrentBossData(completion: @escaping (UserData?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        db.collection(Boss.boss.rawValue).document(uid).getDocument { [weak self](snapshot, error) in
            
            guard let data = snapshot?.data() else {
                completion(nil)
                return
            }
            
            guard let name = data[Boss.name.rawValue] as? String,
                let email = data[Boss.email.rawValue] as? String,
                let truckId = data[Truck.truckId.rawValue] as? String  else { return }
            
            self?.currentUser = UserData(name: name, email: email, truckId: truckId)
            
            completion(self?.currentUser)
        }
    }
    
    func getBossTruck(completion: @escaping (TruckData?) -> Void) {
        
        guard let truckId = currentUser?.truckId else {
            completion(nil)
            return
        }
        
        db.collection(Truck.truck.rawValue).document(truckId).getDocument {(snapshot, error) in
            guard let snapshot = snapshot else {
                return
            }
            
            guard let name = snapshot.data()?[Truck.name.rawValue] as? String,
                let logoImage = snapshot.data()?[Truck.logoImage.rawValue] as? String,
                let open = snapshot.data()?[Truck.open.rawValue] as? Bool,
                let story = snapshot.data()?[Truck.story.rawValue] as? String
                else {return}
            
            self.bossTruck = TruckData(snapshot.documentID, name, logoImage, story, open, nil, nil)
            
            completion(self.bossTruck)
        }
        
    }
    
    func setBossData(name: String, email: String) {
        
        guard let uid = Auth.auth().currentUser?.uid else { return }

        db.collection(Boss.boss.rawValue).document(uid).setData([
            Boss.name.rawValue: name,
            Boss.email.rawValue: email,
            Truck.truckId.rawValue: nil]
        ) { [weak self] error in
            
            if let error = error {
                print("Error adding document: \(error)")
            } else {
                
                self?.currentUser = UserData(name: name, email: email, truckId: nil)
                
                print("Document successfully written!")
            }
        }
        
    }
    
    func addTurckIDInBoss(truckId: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        db.collection(Boss.boss.rawValue).document(uid).updateData([
            Truck.truckId.rawValue: truckId
        ]) { (error) in
            if let err = error {
                print("Error adding document: \(err)")
            }
        }
    }
    
    // MARK: About Register/SingIn
    func userRegister(email: String, psw: String, completion: @escaping () -> Void) {
        
        Auth.auth().createUser(withEmail: email, password: psw) {(authResult, error) in
            
            guard error == nil else {
                
                //TODO: 顯示無法註冊的原因
                print(AuthErrorCode(rawValue: error!._code)?.errorMessage ?? "nil")
                
                return
            }
            print("User Regiuter Success")
            completion()
        }
    }

    func singInWithEmail(email: String, psw: String, completion: @escaping (_ isSuccess: Bool) -> Void) {
        
        Auth.auth().signIn(withEmail: email, password: psw) { (user, error) in
            
            guard error == nil else {
                //TODO: 顯示無法登入的原因
                print("didn't singIn")
                completion(false)
                return
            }
            
            print("Success")
            completion(true)
        }
    }

    func signOut() {
        
        let firebaseAuth = Auth.auth()
        
        do {
            try firebaseAuth.signOut()
            
            self.userID = nil
            self.bossID = nil
            
        } catch let signOutError as NSError {
            
            print ("Error signing out: %@", signOutError)
        }
    }
    
    // MARK: About ChatRoom
    
    func creatChatRoomOne(truckID: String, uid: String, name: String, image: String, text: String) {
        db.collection(Truck.truck.rawValue).document(truckID).collection(
            
            Truck.chatRoom.rawValue).addDocument(data: [
                Truck.name.rawValue: name,
                User.uid.rawValue: uid,
                User.image.rawValue: image,
                User.text.rawValue: text,
                User.createTime.rawValue: Date().timeIntervalSince1970
            ]) { (error) in
                if let err = error {
                    print("Error writing document: \(err)")
                } else {
                    print("Document successfully written!")
                }
        }
    }
    
    func creatChatRoom(truckID: String, truckName: String, uid: String, name: String, text: String) {
        
        db.collection(Truck.truck.rawValue).document(truckID).collection(
            Truck.chatRoom.rawValue).addDocument(data: [
                Truck.name.rawValue: name,
                User.uid.rawValue: uid,
                User.text.rawValue: text,
                User.createTime.rawValue: Date().timeIntervalSince1970
            ]) { (error) in
                
                if let err = error {
                    print("Error writing document: \(err)")
                } else {
                    print("Document successfully written!")
                }
        }
    }

    func observeMessage(truckID: String, completion: @escaping ([Message]) -> Void) {
        
        let docRef = db.collection(Truck.truck.rawValue).document(truckID)
        
        let order = docRef.collection(Truck.chatRoom.rawValue).order(
            by: User.createTime.rawValue,
            descending: false)
        
        order.addSnapshotListener { (snapshot, error) in
            guard let snapshot = snapshot else {
                print("Error fetching document: \(error!)")
                return
            }
            var rtnMessage: [Message] = []
            
            snapshot.documentChanges.forEach({ (documentChange) in
                
                let data = documentChange.document.data()
                guard let uid = data[User.uid.rawValue] as? String,
                    let name = data[User.name.rawValue] as? String,
                    let text = data[User.text.rawValue] as? String,
                    let image = data[User.image.rawValue] as? String,
                    let createTime = data[User.createTime.rawValue] as? Double else {return}
                
                if documentChange.type == .added {
                    
                    rtnMessage.append(Message(uid, name, image, text, createTime))
                }
            })
            if rtnMessage.count > 0 {
                completion(rtnMessage)
            }
        }
    }
}
