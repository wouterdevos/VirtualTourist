//
//  VirtualTouristClient.swift
//  VirtualTourist
//
//  Created by Wouter de Vos on 2015/12/17.
//  Copyright © 2015 Wouter. All rights reserved.
//

import Foundation
import MapKit

class VirtualTouristClient : NSObject {
    
    func taskForPhotosSearch(latitude: Double, longitude: Double, completionHandler: (result: AnyObject?, errorString: String?) -> Void) {
            
        // Specify the header fields and query parameters.
        let headerFields = [String:String]()
        let queryParameters: [String:AnyObject] = [
            QueryKeys.APIKey: Constants.FlickrAPIKey,
            QueryKeys.Method: Methods.PhotosSearch,
            QueryKeys.BBox: createBoundingBoxString(latitude, longitude: longitude),
            QueryKeys.SafeSearch: Constants.SafeSearch,
            QueryKeys.Extras: Constants.Extras,
            QueryKeys.Format: Constants.DataFormat,
            QueryKeys.NoJSONCallback: Constants.NoJSONCallback,
            QueryKeys.PerPage: Constants.PerPage
        ]
        
        // Create url.
        let urlString = Constants.FlickrURL
        
        let restClient = RESTClient.sharedInstance()
        restClient.taskForGETMethod(urlString, headerFields: headerFields, queryParameters: queryParameters) { (data, error) in
            
            if let _ = error {
                completionHandler(result: nil, errorString: "Failed to retrieve photos")
            } else {
                guard let JSONResult = RESTClient.parseJSONWithCompletionHandler(data!) else {
                    completionHandler(result: nil, errorString: "Cannot parse data as JSON!")
                    return
                }
                
                guard let stat = JSONResult[JSONResponseKeys.Stat] as? String where stat == "ok" else {
                    let message = JSONResult[JSONResponseKeys.Message] as? String
                    completionHandler(result: nil, errorString: message)
                    return
                }
                
                guard let photos = JSONResult[JSONResponseKeys.Photos] as? [String:AnyObject] else {
                    completionHandler(result: nil, errorString: "Cannot find key 'photos' in JSON")
                    return
                }
                
                guard let total = (photos[JSONResponseKeys.Total] as? NSString)?.integerValue else {
                    completionHandler(result: nil, errorString: "Cannot find key 'total' in JSON")
                    return
                }
                
                if total > 0 {
                    
                    guard let photoArray = photos[JSONResponseKeys.Photo] as? [[String:AnyObject]] else {
                        completionHandler(result: nil, errorString: "Cannot find key 'photo' in JSON")
                        return
                    }
                    
                    completionHandler(result: photoArray, errorString: nil)
                    return
                }
                
                completionHandler(result: [[String:AnyObject]](), errorString: nil)
            }
        }
    }
    
    func taskForImageDownload(photo: Photo, completionHandler: (imageData: NSData?, errorString: String?) -> Void) {
        
        let restClient = RESTClient.sharedInstance()
        restClient.taskForGETMethod(photo.url, headerFields: [String:String](), queryParameters: nil) { (data, error) in
            
            if let _ = error {
                completionHandler(imageData: nil, errorString: "Failed to download photo with url \(photo.url)")
            } else {
                completionHandler(imageData: data, errorString: nil)
            }
        }
    }
    
    func createBoundingBoxString(latitude: Double, longitude: Double) -> String {
        
        // Fix added to ensure box is bounded by minimum and maximums.
        let bottomLeftLon = max(longitude - Constants.BOUNDING_BOX_HALF_WIDTH, Constants.LON_MIN)
        let bottomLeftLat = max(latitude - Constants.BOUNDING_BOX_HALF_HEIGHT, Constants.LAT_MIN)
        let topRightLon = min(longitude + Constants.BOUNDING_BOX_HALF_HEIGHT, Constants.LON_MAX)
        let topRightLat = min(latitude + Constants.BOUNDING_BOX_HALF_HEIGHT, Constants.LAT_MAX)
        
        return "\(bottomLeftLon),\(bottomLeftLat),\(topRightLon),\(topRightLat)"
    }
    
    class func sharedInstance() -> VirtualTouristClient {
        
        struct Singleton {
            static var sharedInstance = VirtualTouristClient()
        }
        
        return Singleton.sharedInstance
    }
}