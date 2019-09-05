//
//  TurckInfoCollectionViewCell.swift
//  RunRunTruck
//
//  Created by yueh on 2019/8/28.
//  Copyright © 2019 yueh. All rights reserved.
//

import UIKit

struct GeoLocation {
    let lon: Double
    let lat: Double
}

protocol TurckInfoCellDelegate: AnyObject {
    func truckInfoCell(truckInfoCell: TurckInfoCollectionViewCell, didNavigateTo location: GeoLocation )
    //TODO: 前往資訊
    func truckInfoCell(truckInfoCell: TurckInfoCollectionViewCell, didEnterTruckChatRoom truckData: TruckData)
}
class TurckInfoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var truckName: UILabel!
    @IBOutlet weak var truckLocation: UILabel!
    @IBOutlet weak var openTime: UILabel!
    @IBOutlet weak var closeTime: UILabel!
    @IBOutlet weak var clickChatRoomBtn: UIButton!
    @IBOutlet weak var clickNavigateBtn: UIButton!
    
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    weak var delegate: TurckInfoCellDelegate?
    var truckData: TruckData?
    
    func configureWithTruckData(truckData: TruckData) {
        self.truckData = truckData
        clickChatRoomBtn.addTarget(self, action: #selector(onGotoChatRoom), for: .touchUpInside)
    }
    
    func setValue(name: String, openTime: String, closeTime: String, logoImage: String, truckLocationText: String) {
        
        self.truckName.text = name
        self.openTime.text = openTime
        self.closeTime.text = closeTime
        self.truckLocation.text = truckLocationText
        
        if logoImage != "" {
            self.logoImage.loadImage(logoImage)
        } else {
            self.logoImage.image = UIImage.asset(.Icon_logo)
        }
    
        setImage()
    }
    
    @IBAction func clickGoogleMapBtn() {
      self.delegate?.truckInfoCell(truckInfoCell: self, didNavigateTo: GeoLocation(lon: latitude, lat: longitude))
    }
    
    private func setImage() {
        self.logoImage.contentMode = .scaleAspectFill
        self.logoImage.layer.cornerRadius = self.logoImage.frame.width / 2
        self.logoImage.clipsToBounds = true
    }
    
    @objc private func onGotoChatRoom() {
        if let truckData = truckData {
             self.delegate?.truckInfoCell(truckInfoCell: self, didEnterTruckChatRoom: truckData)
        }
    }

}
