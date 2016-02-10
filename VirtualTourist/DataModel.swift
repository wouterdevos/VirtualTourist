//
//  DataModel.swift
//  VirtualTourist
//
//  Created by Wouter de Vos on 2016/02/02.
//  Copyright © 2016 Wouter. All rights reserved.
//

import UIKit
import CoreData

class DataModel {
    
    struct NotificationNames {
        static let SearchPhotos = "com.wouterdevos.SearchPhotos"
        static let SearchPhotosCompleted = "com.wouterdevos.SearchPhotosCompleted"
        static let PhotoDownloadCompleted = "com.wouterdevos.PhotoDownloadCompleted"
    }
    
    var pins = [Pin]()
    
    var context: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    init() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "searchPhotos:", name: NotificationNames.SearchPhotos, object: nil)
    }
    
    func saveContext() {
        CoreDataStackManager.sharedInstance().saveContext()
    }
    
    func removeObservers() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func searchPhotos(pin: Pin) {
        let client = VirtualTouristClient.sharedInstance()
        client.taskForPhotosSearch(pin.getLatitude(), longitude: pin.getLongitude()) { (result, errorString) in
            
            guard let photosArray = result as? [[String:AnyObject]] else {
                print(errorString)
                return
            }
            
            let _ = photosArray.map() { (dictionary: [String:AnyObject]) -> Photo in
                let photo = Photo(dictionary: dictionary, context: self.context)
                photo.pin = pin
                return photo
            }
            
            self.saveContext()
            
            // Post a notification that the photos search has completed.
            NSNotificationCenter.defaultCenter().postNotificationName(NotificationNames.SearchPhotosCompleted, object: nil)
            
            // Download the photos for this pin.
            self.downloadPhotos(pin)
        }
    }
    
    func downloadPhotos(pin: Pin) {
        let client = VirtualTouristClient.sharedInstance()
        for photo in pin.photos {
            client.taskForImageDownload(photo) { (imageData, errorString) in
                
                guard let imageData = imageData else {
                    print(errorString)
                    return
                }
                
                let image = UIImage(data: imageData)
                photo.image = image
                self.saveContext()
                
                // Post a notification that a photo download has completed.
                NSNotificationCenter.defaultCenter().postNotificationName(NotificationNames.PhotoDownloadCompleted, object: nil)
            }
        }
    }
    
    func downloadPhotos(pin: Pin, index: Int) {
        let photos = pin.photos
        let photoCount = photos.count
        if index >= photoCount {
            return
        }
        
        let photo = photos[index]
        let client = VirtualTouristClient.sharedInstance()
        client.taskForImageDownload(photos[index]) { (imageData, errorString) in
            
            guard let imageData = imageData else {
                print(errorString)
                return
            }
            
            let image = UIImage(data: imageData)
            photo.image = image
            self.saveContext()
            
            // Post a notification that a photo download has completed.
            NSNotificationCenter.defaultCenter().postNotificationName(NotificationNames.PhotoDownloadCompleted, object: nil)
            
            self.downloadPhotos(pin, index: index + 1)
        }
    }
    
    class func sharedInstance() -> DataModel {
        
        struct Singleton {
            static var sharedInstance = DataModel()
        }
        
        return Singleton.sharedInstance
    }
    
}
