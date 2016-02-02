//
//  Pin.swift
//  VirtualTourist
//
//  Created by Wouter de Vos on 2016/01/29.
//  Copyright © 2016 Wouter. All rights reserved.
//

import MapKit

class Annotation: MKPointAnnotation {
    
    var pin: Pin
    
    init(pin: Pin) {
        self.pin = pin
    }
}