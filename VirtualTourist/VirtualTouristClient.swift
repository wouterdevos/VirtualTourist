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
    
    func searchPhotos(latitude: Double, longitude: Double, completionHandler: (success: Bool, errorString: String?) -> Void) {
            
        // Specify the header fields and query parameters.
        let headerFields = [String:String]()
        let queryParameters: [String:AnyObject] = [
            QueryKeys.APIKey: Constants.FlickrAPIKey,
            QueryKeys.Method: Methods.PhotosSearch,
            QueryKeys.BBox: createBoundingBoxString(latitude, longitude: longitude),
            QueryKeys.SafeSearch: Constants.SafeSearch,
            QueryKeys.Extras: Constants.Extras,
            QueryKeys.Format: Constants.DataFormat,
            QueryKeys.NoJSONCallback: Constants.NoJSONCallback
        ]
        
        // Create url.
        let urlString = Constants.FlickrURL
        
        let restClient = RESTClient.sharedInstance()
        restClient.taskForGETMethod(urlString, headerFields: headerFields, queryParameters: queryParameters) { (data, error) in
            
            if let _ = error {
                completionHandler(success: false, errorString: "Failed to retrieve photos")
            } else {
                guard let JSONResult = RESTClient.parseJSONWithCompletionHandler(data!) else {
                    completionHandler(success: false, errorString: "Cannot parse data as JSON!")
                    return
                }
                
                guard let stat = JSONResult[JSONResponseKeys.Stat] as? String where stat == "ok" else {
                    let message = JSONResult[JSONResponseKeys.Message] as? String
                    completionHandler(success: false, errorString: message)
                    return
                }
                
                guard let photos = JSONResult[JSONResponseKeys.Photos] as? [String:AnyObject] else {
                    completionHandler(success: true, errorString: "Cannot find key 'photos' in JSON")
                    return
                }
                
                guard let total = (photos[JSONResponseKeys.Total] as? NSString)?.integerValue else {
                    completionHandler(success: true, errorString: "Cannot find key 'total' in JSON")
                    return
                }
                
                if total > 0 {
                    
                    guard let photoArray = photos[JSONResponseKeys.Photo] as? [[String:AnyObject]] else {
                        completionHandler(success: true, errorString: "Cannot find key 'photo' in JSON")
                        return
                    }
                }
                
                guard let results = JSONResult[JSONResponseKeys.Results] as? [[String:AnyObject]] else {
                    completionHandler(success: false, errorString: "Cannot find key 'results' in JSON")
                    return
                }
                
                completionHandler(success: true, errorString: nil)
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
    
    // Get Student Locations
    func getStudentLocations(completionHandler: (success: Bool, errorString: String?) -> Void) {
        
        // Specify header fields.
        let headerFields = getParseHeaderFields()
        
        // Specify query parameters.
        let queryParameters = [
            OnTheMapClient.QueryKeys.Order: "-updateAt"
        ]
        
        // Create url.
        let urlString = OnTheMapClient.Constants.ParseURL + OnTheMapClient.Methods.StudentLocation
        
        let restClient = RESTClient.sharedInstance()
        restClient.taskForGETMethod(urlString, headerFields: headerFields, queryParameters: queryParameters) { (data, error) in
            
            if let _ = error {
                completionHandler(success: false, errorString: "Failed to retrieve student locations")
            } else {
                guard let JSONResult = RESTClient.parseJSONWithCompletionHandler(data!) else {
                    completionHandler(success: false, errorString: "Cannot parse data as JSON!")
                    return
                }
                
                guard let results = JSONResult[OnTheMapClient.JSONResponseKeys.Results] as? [[String:AnyObject]] else {
                    completionHandler(success: false, errorString: "Cannot find key 'results' in JSON")
                    return
                }
                DataModel.sharedInstance().studentLocations = StudentLocation.studentLocationsFromResults(results)
                completionHandler(success: true, errorString: nil)
            }
        }
    }
    
    // Get a Student Location
    func getStudentLocation(completionHandler: (success: Bool, results: [[String:AnyObject]]?, errorString: String?) -> Void) {
        
        // Specify header fields.
        let headerFields = getParseHeaderFields()
        
        // Specify query parameters.
        let queryParameters = [
            OnTheMapClient.QueryKeys.Where: "{\"\(OnTheMapClient.JSONBodyKeys.UniqueKey)\":\"\(DataModel.sharedInstance().key!)\"}"
        ]
        
        // Create url.
        let urlString = OnTheMapClient.Constants.ParseURL + OnTheMapClient.Methods.StudentLocation
        
        let restClient = RESTClient.sharedInstance()
        restClient.taskForGETMethod(urlString, headerFields: headerFields, queryParameters: queryParameters) { (data, error) in
            
            if let _ = error {
                completionHandler(success: false, results: nil, errorString: "Failed to retrieve the student location")
            } else {
                guard let JSONResult = RESTClient.parseJSONWithCompletionHandler(data!) else {
                    completionHandler(success: false, results: nil, errorString: "Cannot parse data as JSON!")
                    return
                }
                
                guard let results = JSONResult[OnTheMapClient.JSONResponseKeys.Results] as? [[String:AnyObject]] else {
                    completionHandler(success: false, results: nil, errorString: "Cannot find key 'results' in JSON")
                    return
                }
                
                completionHandler(success: true, results: results, errorString: nil)
            }
        }
    }
    
    // Post Student Location
    func postStudentLocation(mapString: String, mediaURL: String, location: CLLocation, completionHandler: (success: Bool, errorString: String?) -> Void) {
        
        // Specify header fields and the HTTP body.
        var headerFields = getParseHeaderFields()
        headerFields[OnTheMapClient.HeaderFields.ContentType] = "application/json"
        let bodyParameters: [String:AnyObject] = [
            OnTheMapClient.JSONBodyKeys.UniqueKey: DataModel.sharedInstance().key!,
            OnTheMapClient.JSONBodyKeys.FirstName: DataModel.sharedInstance().firstName!,
            OnTheMapClient.JSONBodyKeys.LastName: DataModel.sharedInstance().lastName!,
            OnTheMapClient.JSONBodyKeys.MapString: mapString,
            OnTheMapClient.JSONBodyKeys.MediaURL: mediaURL,
            OnTheMapClient.JSONBodyKeys.Latitude: location.coordinate.latitude,
            OnTheMapClient.JSONBodyKeys.Longitude: location.coordinate.longitude
        ]
        
        // Create url.
        let urlString = OnTheMapClient.Constants.ParseURL + OnTheMapClient.Methods.StudentLocation
        
        let restClient = RESTClient.sharedInstance()
        restClient.taskForPOSTMethod(urlString, headerFields: headerFields, bodyParameters: bodyParameters) { (data, error) in
            
            if let _ = error {
                completionHandler(success: false, errorString: "Failed to post student location")
            } else {
                completionHandler(success: true, errorString: nil)
            }
        }
    }
    
    func getHeaderFields() -> [String:String] {
        
        let headerFields = [
            OnTheMapClient.HeaderFields.Accept: "application/json",
            OnTheMapClient.HeaderFields.ContentType: "application/json"
        ]
        
        return headerFields
    }
    
    func getParseHeaderFields() -> [String:String] {
        
        let parseHeaderFields = [
            OnTheMapClient.HeaderFields.ParseApplicationID: OnTheMapClient.Constants.ParseAppID,
            OnTheMapClient.HeaderFields.ParseRESTAPIKey: OnTheMapClient.Constants.ParseRESTAPIKey
        ]
        
        return parseHeaderFields
    }
    
    class func sharedInstance() -> OnTheMapClient {
        
        struct Singleton {
            static var sharedInstance = OnTheMapClient()
        }
        
        return Singleton.sharedInstance
    }
}