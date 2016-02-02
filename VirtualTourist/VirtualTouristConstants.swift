//
//  VirtualTouristConstants.swift
//  VirtualTourist
//
//  Created by Wouter de Vos on 2015/12/18.
//  Copyright © 2015 Wouter. All rights reserved.
//

import Foundation

extension VirtualTouristClient {
    
    struct HeaderFields {
        
        static let Accept = "Accept"
        static let ContentType = "Content-Type"
    }
    
    struct Constants {
        
        static let FlickrAPIKey = "ce49425df3d43df821e5bc12a4df5770"
        
        static let FlickrURL = "https://api.flickr.com/services/rest/"
        
        static let SafeSearch = "1"
        static let Extras = "url_m"
        static let DataFormat = "json"
        static let NoJSONCallback = "1"
        
        static let BOUNDING_BOX_HALF_WIDTH = 1.0
        static let BOUNDING_BOX_HALF_HEIGHT = 1.0
        static let LAT_MIN = -90.0
        static let LAT_MAX = 90.0
        static let LON_MIN = -180.0
        static let LON_MAX = 180.0
    }
    
    struct Methods {
        
        static let PhotosSearch = "flickr.photos.search"
    }
    
    struct QueryKeys {
        
        static let Method = "method"
        static let APIKey = "api_key"
        static let BBox = "bbox"
        static let SafeSearch = "safe_search"
        static let Extras = "extras"
        static let Format = "format"
        static let NoJSONCallback = "nojsoncallback"
    }
    
    struct JSONResponseKeys {
        
        static let Stat = "stat"
        static let Message = "message"
        static let Photos = "photos"
        static let Total = "total"
        static let Photo = "photo"
        static let URLM = "url_m"
    }
}