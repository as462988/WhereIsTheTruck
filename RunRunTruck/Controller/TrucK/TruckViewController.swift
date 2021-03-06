//
//  TruckViewController.swift
//  RunRunTruck
//
//  Created by yueh on 2019/9/19.
//  Copyright © 2019 yueh. All rights reserved.
//

import UIKit
import Lottie

class TruckViewController: UIViewController {
    
    @IBOutlet weak var truckCollectionView: UICollectionView! {
        didSet {
            truckCollectionView.delegate = self
            truckCollectionView.dataSource = self
        }
    }
    
    var allTruckData = [TruckData]()
    var openTruckData = [TruckData]()
    var disOpenTruckData = [TruckData]()
    
    let addressManager = AddressManager()
    let dispatchGroup = DispatchGroup()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        handlerOpeningTruck()
        
        handlerDisOpeningTruck()
        
        truckCollectionView.showsVerticalScrollIndicator = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.navigationController?.isNavigationBarHidden = false
    }
    
    func handlerOpeningTruck() {
        FirebaseManager.shared.getOpeningTruckData(isOpen: true) {[weak self] (truckDatas) in
            if let truckDatas = truckDatas {

                for var truckData in truckDatas {

                    switch truckData.1 {
                    case .added:
                        //新增
                        self?.addressManager.getLocationAddress(
                            lat: truckData.0.location!.latitude,
                            long: truckData.0.location!.longitude,
                            completion: {(location, error) in

                                guard let location = location else {return}

                                let address = location.subAdministrativeArea
                                    + location.city + location.street

                                truckData.0.address = address
                                self?.openTruckData.append(truckData.0)

                                DispatchQueue.main.async {
                                    self?.truckCollectionView.reloadData()
                                }
                        })

                    case .removed:
                        //刪除

                        if let index = self?.openTruckData.firstIndex(
                            where: { (truckdata) -> Bool in
                                return truckdata.id == truckData.0.id
                        }) {
                            self?.openTruckData.remove(at: index)
                        }
                    case .modified: break
                    @unknown default:
                        fatalError()
                    }
                }

            }
        }
    }
    
    func handlerDisOpeningTruck() {
        
       FirebaseManager.shared.getOpeningTruckData(isOpen: false) {[weak self] (truckDatas) in
           if let truckDatas = truckDatas {
               
               for var truckData in truckDatas {
                   
                   switch truckData.1 {
                   case .added:
                       //新增
                       if let location = truckData.0.location {
                       self?.addressManager.getLocationAddress(
                           lat: location.latitude,
                           long: location.longitude,
                           completion: {(location, error) in
                               
                               guard let location = location else {return}
                               
                               let address = location.subAdministrativeArea
                                   + location.city + location.street
                               
                               truckData.0.address = address
                               self?.disOpenTruckData.append(truckData.0)
                            
                            DispatchQueue.main.async {
                                self?.truckCollectionView.reloadData()
                            }
                       })
                       
                       } else {
                        self?.disOpenTruckData.append(truckData.0)
                        
                        DispatchQueue.main.async {
                            self?.truckCollectionView.reloadData()
                        }
                    }
                    
                   case .removed:
                       //刪除
                       
                       if let index = self?.disOpenTruckData.firstIndex(
                           where: { (truckdata) -> Bool in
                               return truckdata.id == truckData.0.id
                       }) {
                           self?.disOpenTruckData.remove(at: index)
                       }
                   case .modified: break
                   @unknown default:
                       fatalError()
                   }
               }
               
           }
       }
    }
}

extension TruckViewController:
UICollectionViewDelegate,
UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return openTruckData.count + disOpenTruckData.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let truckCell = collectionView.dequeueReusableCell(
            withReuseIdentifier: String(describing: TruckCollectionViewCell.self),
            for: indexPath) as? TruckCollectionViewCell else {
                return UICollectionViewCell()
        }
        
        allTruckData = openTruckData + disOpenTruckData
        
        let data = allTruckData[indexPath.item]
        
        truckCell.setValue(name: data.name,
                           logoImage: data.logoImage,
                           image: data.detailImage ?? "",
                           isOpen: data.open)

        return truckCell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let itemSize = CGSize(
            width: UIScreen.main.bounds.width - 32,
            height: UIScreen.main.bounds.height / 6 - 10)
        
        return itemSize
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.hidesBottomBarWhenPushed = true
        
        guard let truckVC = UIStoryboard.truck.instantiateViewController(
            withIdentifier: String(describing: TruckDetailViewController.self)) as? TruckDetailViewController
            else {return}
        
        truckVC.detailInfo = allTruckData[indexPath.item]
        
        navigationController?.isNavigationBarHidden = true
        navigationController?.pushViewController(truckVC, animated: true)
        self.hidesBottomBarWhenPushed = false
    }
    
}
