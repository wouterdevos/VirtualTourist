//
//  Pin.swift
//  VirtualTourist
//
//  Created by Wouter de Vos on 2016/01/31.
//  Copyright © 2016 Wouter. All rights reserved.
//

import CoreData
import MapKit

class Pin: NSManagedObject {
    
    @NSManaged var latitude: NSNumber
    @NSManaged var longitude: NSNumber
    @NSManaged var page: NSNumber
    @NSManaged var photos: [Photo]
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(latitude: Double, longitude: Double, context: NSManagedObjectContext) {
        
        let entity = NSEntityDescription.entityForName("Pin", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        self.latitude = latitude as NSNumber
        self.longitude = longitude as NSNumber
        self.page = 1
    }
    
    func getLatitude() -> Double {
        return Double(latitude)
    }
    
    func getLongitude() -> Double {
        return Double(longitude)
    }
}