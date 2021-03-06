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
        static let PerPage = 21
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
        static let PerPage = "per_page"
        static let Page = "page"
        static let Lat = "lat"
        static let Lon = "lon"
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