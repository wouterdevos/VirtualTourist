//
//  DataModel.swift
//  VirtualTourist
//
//  Created by Wouter de Vos on 2016/02/02.
//  Copyright © 2016 Wouter. All rights reserved.
//

let PhotoDownloadComplete = "com.wouterdevos.PhotoDownloadComplete"

class DataModel {
    
    var pins = [Pin]()
    
    init() {
        
    }
    
    func addPin(latitude: Double, longitude: Double, photos: [String:AnyObject]) {
        
    }
    
    class func sharedInstance() -> DataModel {
        
        struct Singleton {
            static var sharedInstance = DataModel()
        }
        
        return Singleton.sharedInstance
    }
    
}
