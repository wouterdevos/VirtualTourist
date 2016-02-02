//
//  Pin.swift
//  VirtualTourist
//
//  Created by Wouter de Vos on 2016/01/31.
//  Copyright © 2016 Wouter. All rights reserved.
//

import Foundation

class Pin: NSObject {
    
    var latitude: Double
    var longitude: Double
    var photos = [Photo]()
    
    init(latitude: Double, longitude: Double, photos: [Photo]) {
        self.latitude = latitude
        self.longitude = longitude
        self.photos = photos
    }
}