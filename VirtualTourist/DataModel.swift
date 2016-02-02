//
//  DataModel.swift
//  VirtualTourist
//
//  Created by Wouter de Vos on 2016/02/02.
//  Copyright © 2016 Wouter. All rights reserved.
//

class DataModel {
    
    var photos = [Photo]()
    
    func savePhotos(latitude: Double, longitude: Double, photos: [String:AnyObject]) {
        
    }
    
    class func sharedInstance() -> DataModel {
        
        struct Singleton {
            static var sharedInstance = DataModel()
        }
        
        return Singleton.sharedInstance
    }
}
