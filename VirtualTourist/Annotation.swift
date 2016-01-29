//
//  Pin.swift
//  VirtualTourist
//
//  Created by Wouter de Vos on 2016/01/29.
//  Copyright © 2016 Wouter. All rights reserved.
//

import MapKit

class Annotation: NSObject, MKAnnotation {
    
    var location: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    
    var coordinate: CLLocationCoordinate2D {
        get {
            return location
        }
    }
    
    func setCoordinate(coordinate: CLLocationCoordinate2D) {
        willChangeValueForKey("coordinate")
        self.location = coordinate
        didChangeValueForKey("coordinate")
    }
}