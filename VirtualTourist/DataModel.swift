//
//  DataModel.swift
//  VirtualTourist
//
//  Created by Wouter de Vos on 2016/02/02.
//  Copyright © 2016 Wouter. All rights reserved.
//

import UIKit
import CoreData

class DataModel: NSObject {
    
    struct NotificationNames {
        static let SearchPhotosStarted = "com.wouterdevos.SearchPhotosStarted"
        static let SearchPhotosPending = "com.wouterdevos.SearchPhotosPending"
        static let SearchPhotosCompleted = "com.wouterdevos.SearchPhotosCompleted"
        static let PhotoDownloadCompleted = "com.wouterdevos.PhotoDownloadCompleted"
        static let AllPhotoDownloadsCompleted = "com.wouterdevos.AllPhotoDownloadsCompleted"
    }
    
    private class var defaultCenter: NSNotificationCenter {
        return NSNotificationCenter.defaultCenter()
    }
    
    private class var context: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    private class func saveContext() {
        CoreDataStackManager.sharedInstance().saveContext()
    }
    
    class func fetchPin(createdAt: NSDate) -> Pin? {
        let request = NSFetchRequest(entityName: "Pin")
        request.sortDescriptors = [NSSortDescriptor(key: "latitude", ascending: true)]
        request.predicate = NSPredicate(format: "createdAt == %@", createdAt)
        
        var pins: [Pin]? = nil
        do {
            pins = try context.executeFetchRequest(request) as? [Pin]
        } catch let error as NSError {
            print("Error in fetchPin \(error)")
        }
        
        return pins?[0] ?? Pin()
    }
    
    class func searchPhotos(createdAt: NSDate, isNewCollection: Bool) {
        guard let pin = fetchPin(createdAt) else {
            print("No pin for date \(createdAt)")
            return
        }
        
        if isNewCollection {
            var page = pin.photosMetaData.page.integerValue
            let pages = pin.photosMetaData.pages.integerValue
            page = page < pages ? ++page : 1
            
            // Remove the old data from the pin.
            context.deleteObject(pin.photosMetaData)
            for photo in pin.photos {
                context.deleteObject(photo)
            }
            
            // Configure the pin properties.
            pin.page = page
            pin.isDownloading = true
            
            saveContext()
            searchPhotos(pin)
        } else {
            if pin.isDownloading {
                // Post a notification that the photos search is pending.
                defaultCenter.postNotificationName(NotificationNames.SearchPhotosPending, object: nil)
            } else {
                // Post a notification that the photos search has completed.
                defaultCenter.postNotificationName(NotificationNames.SearchPhotosCompleted, object: nil)
                
                if pin.hasAllPhotos() {
                    // Post a notification that all photo downloads have completed.
                    defaultCenter.postNotificationName(NotificationNames.AllPhotoDownloadsCompleted, object: nil)
                } else {
                    downloadPhotos(pin)
                }
            }
        }
    }
    
    class func searchPhotos(pin: Pin) {
        // Post a notification that the photos search has started.
        defaultCenter.postNotificationName(NotificationNames.SearchPhotosStarted, object: nil)
        
        let client = VirtualTouristClient.sharedInstance()
        client.taskForPhotosSearch(pin) { (result, errorString) in
            
            guard let photos = result as? [String:AnyObject] else {
                print(errorString)
                return
            }
            
            guard let photosArray = photos[VirtualTouristClient.JSONResponseKeys.Photo] as? [[String:AnyObject]] else {
                print(errorString)
                return
            }
            
            // Store the photos meta data in the pin
            let photosMetaData = PhotosMetaData(dictionary: photos, context: self.context)
            pin.photosMetaData = photosMetaData
            
            // Store the photos in the pin
            let _ = photosArray.map() { (dictionary: [String:AnyObject]) -> Photo in
                let photo = Photo(dictionary: dictionary, context: context)
                photo.pin = pin
                return photo
            }
            
            pin.isDownloading = false
            
            saveContext()
            
            // Post a notification that the photos search has completed.
            defaultCenter.postNotificationName(NotificationNames.SearchPhotosCompleted, object: nil)
            
            // Download the photos for this pin.
            downloadPhotos(pin)
        }
    }
    
    private class func downloadPhotos(pin: Pin) {
        let client = VirtualTouristClient.sharedInstance()
        let photos = pin.photos
        var total = pin.photos.count
        var count = 0
        
        for photo in photos {
            // Don't download photos that have already been downloaded.
            if photo.downloaded {
                // Decrement the total since there is one less photo to download.
                total--
                continue
            }
            
            client.taskForImageDownload(photo) { (imageData, errorString) in
                
                guard let imageData = imageData else {
                    print(errorString)
                    return
                }
                
                let image = UIImage(data: imageData)
                photo.image = image
                saveContext()
                
                // Post a notification that a photo download has completed.
                defaultCenter.postNotificationName(NotificationNames.PhotoDownloadCompleted, object: nil)
                
                count++
                if count == total {
                    // Post a notification that all photo downloads have completed.
                    defaultCenter.postNotificationName(NotificationNames.AllPhotoDownloadsCompleted, object: nil)
                }
            }
        }
    }
}
