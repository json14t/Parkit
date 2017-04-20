//
//  GpsLocation.swift
//  Parkit
//
//  Created by Jason Campoverde on 3/31/17.
//  Copyright © 2017 Jason Campoverde. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit

class GpsLocation {
    //Variable declarations
    static var sharedInstance = GpsLocation()
    var coordinates: CLLocation?
    var latitude: Double?
    var longitude: Double?
    
    private init(){
        if coordinates == nil{
            print("coordinates are nil")
            coordinates = CLLocation(latitude: 37.332211, longitude: -122.030778)
            latitude = 37.332211
            longitude = -122.030778
        } else{
            latitude = coordinates?.coordinate.latitude
            longitude = coordinates?.coordinate.longitude
            print("coordinates are not nil")
        }
    }
    
}
