//
//  PinAnnotation.swift
//  VirtualTourist
//
//  Created by Wouter de Vos on 2016/02/15.
//  Copyright © 2016 Wouter. All rights reserved.
//

import MapKit

class PinAnnotation: MKPointAnnotation {
    
    var pin: Pin?
    var createdAt: NSDate?
    
    override init() {
        super.init()
    }
}