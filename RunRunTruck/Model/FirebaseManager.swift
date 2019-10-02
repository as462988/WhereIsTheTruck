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
    
    static let userNotificationName = "userInfoUpdatedNotificaton"
    static let allTruckDataNotificationName = "allTruckDataUpdatedNotification"
    
    static let shared = FirebaseManager()
    
    var openIngTruckData = [TruckData]()
    
    var allTruckData = [TruckData]()
    
    var currentUser: UserData?
    
    var bossTruck: TruckData?
    
    var message = [Message]()
    
    var currentUserToken: String = ""
    
    let db = Firestore.firestore()
    
    var truckID: String?
    
    var userID: String?
    
    var bossID: String?
    
    // MARK: About Truck
    //getAllTruck
    
    func listenAllTruckData() {
        
        db.collection(Truck.truck.rawValue).addSnapshotListener { (snapshot, error) in
            guard error == nil else { return }
            var openTimestamp: Double?
            var location: GeoPoint?
            var detailImage: String?
            
            snapshot?.documentChanges.forEach({ (documentChange) in
                if documentChange.type == .added {
                    let data = documentChange.document.data()
                    
                    guard let name = data[Truck.name.rawValue] as? String,
                        let logoImage = data[Truck.logoImage.rawValue] as? String,
                        let open = data[Truck.open.rawValue] as? Bool,
                        let story = data[Truck.story.rawValue] as? String,
                        let favorited = data[Truck.favoritedBy.rawValue] as? [String] else {return}
                    
                    openTimestamp = data[Truck.openTime.rawValue] as? Double
                    location = data[Truck.location.rawValue] as? GeoPoint
                    detailImage = data[Truck.detailImage.rawValue] as? String
                    
                    let truck = TruckData(documentChange.document.documentID,
                                          name, logoImage,
                                          detailImage,
                                          story,
                                          open,
                                          openTimestamp,
                                          location,
                                          favorited)
                    self.allTruckData.append(truck)
                }
            })
            NotificationCenter.default.post(
                name: Notification.Name(FirebaseManager.allTruckDataNotificationName),
                object: nil)
        }
    }
    
    func getOpeningTruckData(isOpen: Bool, completion: @escaping ([(TruckData, DocumentChangeType)]?) -> Void) {
        
        var openTimestamp: Double?
        var location: GeoPoint?
        var detailImage: String?
        
        db.collection(Truck.truck.rawValue).whereField(
            Truck.open.rawValue, isEqualTo: isOpen).addSnapshotListener { (snapshot, error) in
                
                guard let snapshot = snapshot else { return }
                
                var rtnTruckDatas: [(TruckData, DocumentChangeType)] = []
                snapshot.documentChanges.forEach({ (documentChange) in
                    let data = documentChange.document.data()
                    
                    guard let name = data[Truck.name.rawValue] as? String,
                        let logoImage = data[Truck.logoImage.rawValue] as? String,
                        let open = data[Truck.open.rawValue] as? Bool,
                        let story = data[Truck.story.rawValue] as? String,
                        let favorited = data[Truck.favoritedBy.rawValue] as? [String] else {return}
                    
                    openTimestamp = data[Truck.openTime.rawValue] as? Double
                    location = data[Truck.location.rawValue] as? GeoPoint
                    detailImage = data[Truck.detailImage.rawValue] as? String
                    
                    let truck = TruckData(documentChange.document.documentID,
                                          name, logoImage,
                                          detailImage,
                                          story,
                                          open,
                                          openTimestamp,
                                          location,
                                          favorited)
                    
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
            Truck.open.rawValue: false,
            Truck.favoritedBy.rawValue: []
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
            
            guard let lat = lat, let lon = lon else { return }
            
            let location = GeoPoint(latitude: lat, longitude: lon)
            
            db.collection(Truck.truck.rawValue).document(truckId).updateData([
                Truck.open.rawValue: status,
                Truck.openTime.rawValue: Date().timeIntervalSince1970,
                Truck.location.rawValue: location
            ])
        } else {
            
            db.collection(Truck.truck.rawValue).document(truckId).updateData([
                Truck.open.rawValue: status
            ])
        }
    }

    func getTruckId(truckName: String) {
        
        db.collection(Truck.truck.rawValue).whereField(
            Truck.name.rawValue,
            isEqualTo: truckName).getDocuments {[weak self] (snapshot, error) in
                
                guard let snapshot = snapshot else { return }
                
                for document in snapshot.documents {
                    self?.truckID = document.documentID
                    
                }
        }
    }
    
    // MARK: About All
    func updataData(type: String, uid: String, key: String, value: String) {

        db.collection(type).document(uid).updateData([ key: value ])
    }
    
    func updataArrayData(type: String, id: String, key: String, value: String, completion: @escaping () -> Void) {
        
        db.collection(type).document(id).updateData([key: FieldValue.arrayUnion([value])]) { (error) in
            
            if let error = error {
                print("Error adding document: \(error)")
            } else {
                completion()
            }
        }
    }
    
    func updataRemoveArrayData(type: String, id: String, key: String, value: String, completion: @escaping () -> Void) {
        db.collection(type).document(id).updateData([key: FieldValue.arrayRemove([value])]) { (error) in
                 
                 if let error = error {
                     print("Error adding document: \(error)")
                 } else {
                     completion()
                 }
             }
    }
    
    // MARK: About User
    ///開始監聽使用者資料變更
    func listenUserData(isAppleSingIn: Bool, userid: String? = nil) {
        
        var currentUser: String = ""
        
        if isAppleSingIn {
            guard let userId = userid else {return}
            currentUser = userId
        } else {
            guard let uid = Auth.auth().currentUser?.uid else { return }
            currentUser = uid
        }

        db.collection(User.user.rawValue).document(currentUser).addSnapshotListener { [weak self ] (snapshot, error) in

            guard let snapshot = snapshot else { return }
            
            guard let data = snapshot.data() else {
                print("Document data was empty.")
                return
            }

            guard let name = data[User.name.rawValue] as? String,
                let email = data[User.email.rawValue] as? String,
                let badge = data[User.badge.rawValue] as? [String],
                let block = data[User.block.rawValue] as? [String],
                let token = data[User.token.rawValue] as? String,
                let favorite = data[User.favorite.rawValue] as? [String] else { return }
            
            if let image = data[User.logoImage.rawValue] as? String {
                
                self?.currentUser = UserData(name: name, email: email,
                                             token: token,
                                             logoImage: image, badge: badge,
                                             block: block, favorite: favorite)
            } else {
                
                self?.currentUser = UserData(name: name, email: email,
                                             token: token,
                                             badge: badge, block: block,
                                             favorite: favorite)
            }
            NotificationCenter.default.post(name: Notification.Name(FirebaseManager.userNotificationName), object: nil)
        }
    }
    
    func getCurrentUserData(useAppleSingIn: Bool, userId: String? = nil, completion: @escaping (UserData?) -> Void) {
       
        var currentUser: String = ""
        
        if useAppleSingIn {
            if let userId = userId {
                currentUser = userId
            }
        } else {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        currentUser = uid
        }
        db.collection(User.user.rawValue).document(currentUser).getDocument { [weak self ] (snapshot, error) in
            
            guard let document = snapshot else {
                completion(nil)
                return
            }
            guard let data = document.data() else { return }
            
            guard let name = data[User.name.rawValue] as? String,
                let email = data[User.email.rawValue] as? String,
                let token = data[User.token.rawValue] as? String,
                let badge = data[User.badge.rawValue] as? [String],
                let block = data[User.block.rawValue] as? [String],
                let favorite = data[User.favorite.rawValue] as? [String]else { return }
            
            if let image = data[User.logoImage.rawValue] as? String {
                
                self?.currentUser = UserData(name: name, email: email,
                                             token: token,
                                             logoImage: image, badge: badge,
                                             block: block, favorite: favorite)
            } else {
                
                self?.currentUser = UserData(name: name, email: email,
                                             token: token, badge: badge,
                                             block: block, favorite: favorite)
            }
            
            completion(self?.currentUser)
        }
    }
    
    func setUserData(name: String, email: String, isAppleSingIn: Bool, appleUID: String = "") {
        
        var userid = ""
        if isAppleSingIn {
            userid = appleUID
        } else {
            guard let authUid = Auth.auth().currentUser?.uid else { return }
            userid = authUid
        }
        
        db.collection(User.user.rawValue).document(userid).setData([
            User.name.rawValue: name,
            User.email.rawValue: email,
            User.badge.rawValue: [],
            User.block.rawValue: [],
            User.favorite.rawValue: []
        ]) { error in
            if let error = error {
                print("Error adding document: \(error)")
            }
        }
    }

    func getBlockUserName(blockId: String, completion: @escaping (String?) -> Void) {
        
        db.collection(User.user.rawValue).document(blockId).getDocument { (snapshot, error) in
            
            guard let data = snapshot?.data() else {
                print("Document data was empty.")
                completion(nil)
                return
            }
            
            guard let name = data[User.name.rawValue] as? String else {return}
            
            completion(name)
        }
    }

    func getUserFavoriteTruck(truckId: String, completion: @escaping (TruckShortInfo?) -> Void) {
        
        db.collection(Truck.truck.rawValue).document(truckId).getDocument { (snapshot, error) in
            guard let data = snapshot?.data() else {
                print("Document data was empty.")
                completion(nil)
                return
            }
            guard let truckId = data[Truck.truckId.rawValue] as? String,
                let name = data[Truck.name.rawValue] as? String,
                let logoImage = data[Truck.logoImage.rawValue] as? String else {return }
            
            let truck = TruckShortInfo(truckId: truckId, name: name, logoImage: logoImage)
            completion(truck)
        }
    }
    
    // MARK: About Boss
    func getCurrentBossData(isAppleSingIn: Bool, userid: String? = nil, completion: @escaping (UserData?) -> Void) {
        
        var currentBoss: String = ""
        
        if isAppleSingIn {
            
            guard let userId = userid else { return }
            currentBoss = userId
            
        } else {
             guard let uid = Auth.auth().currentUser?.uid else { return }
            currentBoss = uid
        }
        
        db.collection(Boss.boss.rawValue).document(currentBoss).getDocument { [weak self](snapshot, error) in
            
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
        
        var detailImage: String?
        
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
                let story = snapshot.data()?[Truck.story.rawValue] as? String,
                let favoritedBy = snapshot.data()?[Truck.favoritedBy.rawValue] as? [String]
                else {return}
            
            detailImage = snapshot.data()?[Truck.detailImage.rawValue] as? String
            
            self.bossTruck = TruckData(snapshot.documentID,
                                       name, logoImage, detailImage,
                                       story, open, nil, nil, favoritedBy)
            
            completion(self.bossTruck)
        }
        
    }
    
    func setBossData(name: String, email: String, isAppleSingIn: Bool, appleUID: String = "") {
        
        var userid = ""
        
        if isAppleSingIn {
            userid = appleUID
        } else {
            guard let authUid = Auth.auth().currentUser?.uid else { return }
            userid = authUid
        }
        
        db.collection(Boss.boss.rawValue).document(userid).setData([
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
    
    func addTurckIDInBoss(isAppleSingIn: Bool, appleID: String? = nil, truckId: String) {
        
        guard isAppleSingIn  else {
            
            guard let uid = Auth.auth().currentUser?.uid else { return }
            
            db.collection(Boss.boss.rawValue).document(uid).updateData([
                Truck.truckId.rawValue: truckId
            ])
            return
        }
        
        db.collection(Boss.boss.rawValue).document(appleID!).updateData([
                Truck.truckId.rawValue: truckId
            ])
    }
    
    // MARK: About Register/SingIn
    func userRegister(email: String, psw: String, completion: @escaping (_ isSuccess: Bool, String) -> Void) {
        
        Auth.auth().createUser(withEmail: email, password: psw) {(authResult, error) in
            
            guard error == nil else {
                
                guard let errorCode = AuthErrorCode(rawValue: error!._code) else {return}
                completion(false, errorCode.errorMessage)
                return
            }
            completion(true, "Success")
        }
    }
    
    func singInWithEmail(email: String, psw: String, completion: @escaping (_ isSuccess: Bool, String) -> Void) {
        
        Auth.auth().signIn(withEmail: email, password: psw) { (user, error) in
            
            guard error == nil else {
                
                guard let errorCode = AuthErrorCode(rawValue: error!._code) else {return}
                completion(false, errorCode.errorMessage)
                return
            }
            
            completion(true, "Success")
        }
    }
    
    func signOut() {
        
        let firebaseAuth = Auth.auth()
        
        do {
            try firebaseAuth.signOut()
            
            self.userID = nil
            self.bossID = nil
            
        } catch _ as NSError {
        }
    }
    
    func checkExistUser(userType: String, uid: String, completion: @escaping (Bool) -> Void) {
        
        db.collection(userType).document(uid).getDocument { (snapshot, error) in
            
            guard snapshot?.data() != nil else {
                completion(false)
                return
            }
            completion(true)
        }
    }
    // MARK: About ChatRoom
    
    func creatChatRoom(truckID: String, uid: String, name: String, image: String?, text: String) {
        
        db.collection(Truck.truck.rawValue).document(truckID).collection(
            Truck.chatRoom.rawValue).addDocument(data: [
                Truck.name.rawValue: name,
                User.uid.rawValue: uid,
                User.logoImage.rawValue: image,
                User.text.rawValue: text,
                User.createTime.rawValue: Date().timeIntervalSince1970
            ])
    }

    func deleteChatRoom(truckID: String) {
        
        let collection = db.collection(Truck.truck.rawValue).document(truckID).collection(Truck.chatRoom.rawValue)
        
        collection.getDocuments { (snapshot, error) in
            
            guard let snapshot = snapshot else {return}
            
            let docs = snapshot.documents
            
            for doc in docs {
                
                collection.document(doc.documentID).delete()
                
            }
        }
    }
    
    func observeMessage(truckID: String, completion: @escaping ([Message]) -> Void) {
        
        let docRef = db.collection(Truck.truck.rawValue).document(truckID)
        
        let order = docRef.collection(Truck.chatRoom.rawValue).order(
            by: User.createTime.rawValue,
            descending: false)
        
        order.addSnapshotListener { (snapshot, error) in
            guard let snapshot = snapshot else { return }
            var rtnMessage: [Message] = []
            
            var image: String?
            
            snapshot.documentChanges.forEach({ (documentChange) in
                
                let data = documentChange.document.data()
                guard let uid = data[User.uid.rawValue] as? String,
                    let name = data[User.name.rawValue] as? String,
                    let text = data[User.text.rawValue] as? String,
                    let createTime = data[User.createTime.rawValue] as? Double else {return}
                
                image = data[User.logoImage.rawValue] as? String
                
                if documentChange.type == .added {
                    
                    rtnMessage.append(Message(uid, name, image, text, createTime))
                }
            })
            if rtnMessage.count > 0 {
                completion(rtnMessage)
            }
        }
    }
    
    func creatFeedback(user: String, uid: String, title: String, detailText: String) {
        
        db.collection(user).document(uid).collection(Feedback.feedback.rawValue).addDocument(data: [
                Feedback.title.rawValue: title,
                Feedback.detailText.rawValue: detailText,
                User.createTime.rawValue: Date().timeIntervalSince1970
            ]) { (error) in
                if let err = error {
                    print("Error writing document: \(err)")
                } else {
                    print("Document successfully written!")
                }
        }
    }

}
