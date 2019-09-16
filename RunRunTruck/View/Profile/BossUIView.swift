//
//  BossUIView.swift
//  RunRunTruck
//
//  Created by yueh on 2019/9/10.
//  Copyright © 2019 yueh. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreLocation
import Contacts

class BossUIView: UIView {

    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var storyTextView: UITextView!
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var logoOutBtn: UIButton!
    @IBOutlet weak var openSwitch: UISwitch!

    //open View
    @IBOutlet weak var openView: UIView!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var openBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setRadius()
        setMapView()
        openView.isHidden = true
        
        logoOutBtn.addTarget(self, action: #selector(clickLogoutBtn), for: .touchUpInside)
    
        openSwitch.addTarget(self, action: #selector(onChange), for: .valueChanged)
        
        cancelBtn.addTarget(self, action: #selector(clickCancelBtn), for: .touchUpInside)
        
        openBtn.addTarget(self, action: #selector(clickChenckBtn), for: .touchUpInside)

    }
    
    @objc func clickChenckBtn() {
        openSwitch.isOn = true
        FirebaseManager.shared.changeOpenStatus(status: openSwitch.isOn, lat: 25.042447, lon: 121.551958)
        openView.isHidden = true
    }
    
    @objc func clickCancelBtn() {
        openView.isHidden = true
        openSwitch.isOn = false
        FirebaseManager.shared.closeOpenStatus(status: openSwitch.isOn)
    }
    
    @objc func onChange(sender: AnyObject) {
        
        guard let tempSwitch = sender as? UISwitch else {return}
        
        if tempSwitch.isOn {
            
            openView.isHidden = false
            getLocation(lat: 25.042447, long: 121.551958) { [weak self] (location, error) in
              
                guard let location = location else {return}
                
                self?.addressLabel.text = location.subAdministrativeArea
                    + location.city + location.street

            }
            
        } else {
            openView.isHidden = true
        }
    }
    
    func getLocation(lat: Double, long: Double, completion: @escaping (CNPostalAddress?, Error?) -> Void) {
        let locale = Locale(identifier: "zh_TW")
        
        let loc: CLLocation = CLLocation(latitude: lat, longitude: long)
        
        CLGeocoder().reverseGeocodeLocation(loc, preferredLocale: locale) { placemarks, error in
            
            guard let placemark = placemarks?.first, error == nil else {
                
                UserDefaults.standard.removeObject(forKey: "AppleLanguages")
                
                completion(nil, error)
                
                return
            }
            completion(placemark.postalAddress, nil)
        }
    }
    
    func setMapView() {
        
        let camera = GMSCameraPosition.camera(withLatitude: 25.033128, longitude: 121.565806, zoom: 15)
        mapView.camera = camera
        mapView.settings.myLocationButton = true
        mapView.isMyLocationEnabled = true

    }

    func setupValue(name: String, story: String, image: String, open: Bool) {

        logoImage.loadImage(image, placeHolder: UIImage.asset(.Icon_logo))
        nameLabel.text = name
        storyTextView.text = story
        openSwitch.isOn = open
    }
    
    func cleanValue() {
        nameLabel.text = ""
        storyTextView.text = ""
    }
    
    func setRadius() {
        
        logoImage.layer.cornerRadius = 25
        logoImage.clipsToBounds = true
        editBtn.layer.cornerRadius = 10
        editBtn.clipsToBounds = true
        logoOutBtn.layer.cornerRadius = 10
        logoOutBtn.clipsToBounds = true
        storyTextView?.layer.cornerRadius = 10
        storyTextView?.clipsToBounds = true
        openView.layer.cornerRadius = 10
        openView.clipsToBounds = true
        openBtn.layer.cornerRadius = 10
        openBtn.clipsToBounds = true
        cancelBtn.layer.cornerRadius = 10
        cancelBtn.clipsToBounds = true
    
    }
    
    @objc func clickLogoutBtn() {
        
        FirebaseManager.shared.signOut()
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        
        let root = appDelegate?.window?.rootViewController as? TabBarViewController
        
        root?.selectedIndex = 0
        
        cleanValue()
    }
}
