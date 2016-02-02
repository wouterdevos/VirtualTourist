//
//  RESTClient.swift
//  VirtualTourist
//
//  Created by Wouter de Vos on 2015/12/13.
//  Copyright © 2015 Wouter. All rights reserved.
//

import Foundation

class RESTClient: NSObject {

    var session : NSURLSession
    
    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }
    
    func taskForGETMethod(var urlString: String, headerFields: [String:String], queryParameters: [String:AnyObject]?, completionHandler: (data: NSData?, error: NSError?)-> Void) -> NSURLSessionDataTask {
        
        // Build the URL and configure the request
        urlString += RESTClient.escapedParameters(queryParameters)
        let url = NSURL(string: urlString)!
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = RESTClient.HTTPMethods.GET
        for (field, value) in headerFields {
            request.addValue(value, forHTTPHeaderField: field)
        }
        
        // Make the request
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            if self.isSuccess(data, response: response, error: error, completionHandler: completionHandler) {
                completionHandler(data: data, error: nil)
            }
        }
        
        task.resume()
        
        return task
    }
    
    func taskForPOSTMethod(urlString: String, headerFields: [String:String], bodyParameters: [String:AnyObject], completionHandler: (data: NSData?, error: NSError?)-> Void) -> NSURLSessionDataTask {
        
        // Build the URL and configure the request
        let url = NSURL(string: urlString)!
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = RESTClient.HTTPMethods.POST
        for (field, value) in headerFields {
            request.addValue(value, forHTTPHeaderField: field)
        }
        do {
            request.HTTPBody = try! NSJSONSerialization.dataWithJSONObject(bodyParameters, options: .PrettyPrinted)
        }
        
        // Make the request
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            if self.isSuccess(data, response: response, error: error, completionHandler: completionHandler) {
                completionHandler(data: data, error: nil)
            }
        }
        
        task.resume()
        
        return task
    }
    
    func taskForPUTMethod(urlString: String, headerFields: [String:String], completionHandler: (data: NSData?, error: NSError?)-> Void) -> NSURLSessionDataTask {
        
        // Build the URL and configure the request
        let url = NSURL(string: urlString)!
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = RESTClient.HTTPMethods.PUT
        for (field, value) in headerFields {
            request.addValue(value, forHTTPHeaderField: field)
        }
        
        // Make the request
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            if self.isSuccess(data, response: response, error: error, completionHandler: completionHandler) {
                completionHandler(data: data, error: nil)
            }
        }
        
        task.resume()
        
        return task
    }
    
    func taskForDELETEMethod(urlString: String, headerFields: [String:String], completionHandler: (data: NSData?, error: NSError?)-> Void) -> NSURLSessionDataTask {
        
        // Build the URL and configure the request
        let url = NSURL(string: urlString)!
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = RESTClient.HTTPMethods.DELETE
        for (field, value) in headerFields {
            request.addValue(value, forHTTPHeaderField: field)
        }
        
        // Make the request
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            if self.isSuccess(data, response: response, error: error, completionHandler: completionHandler) {
                completionHandler(data: data, error: nil)
            }
        }
        
        task.resume()
        
        return task
    }
    
    func isSuccess(data: NSData?, response: NSURLResponse?, error: NSError?, completionHandler: (data: NSData?, error: NSError?) -> Void) -> Bool {
        
        guard error == nil else {
            print("There was an error with your request: \(error)")
            completionHandler(data: nil, error: error)
            return false
        }
        
        guard let data = data else {
            let errorMessage = "No data was returned by the request!"
            print(errorMessage)
            let userInfo = [NSLocalizedDescriptionKey : errorMessage]
            completionHandler(data: nil, error: NSError(domain: "isSuccess", code: 1, userInfo: userInfo))
            return false
        }
        
        guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
            var errorMessage : String
            if let response = response as? NSHTTPURLResponse {
                errorMessage = "Your request returned an invalid response! Status code \(response.statusCode)!"
            } else if let response = response {
                errorMessage = "Your request returned an invalid response! Response \(response)!"
            } else {
                errorMessage = "Your request returned an invalid response!"
            }
            
            print(errorMessage)
            let userInfo = [NSLocalizedDescriptionKey : errorMessage]
            completionHandler(data: data, error: NSError(domain: "isSuccess", code: 1, userInfo: userInfo))
            return false
        }
        
        return true
    }
    
    /* Helper: Skip the first 5 characters of the response data */
    class func skipResponseCharacters(data: NSData) -> NSData {
        let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
        return newData
    }
    
    /* Helper: Given raw JSON, return a usable Foundation object */
    class func parseJSONWithCompletionHandler(data: NSData) -> AnyObject? {
        
        var parsedResult: AnyObject?
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
        } catch {
            parsedResult = nil
        }
        
        return parsedResult
    }
    
    /* Helper function: Given a dictionary of parameters, convert to a string for a url */
    class func escapedParameters(parameters: [String : AnyObject]?) -> String {
        
        guard let parameters = parameters else {
            return ""
        }
        
        var urlVars = [String]()
        
        for (key, value) in parameters {
            
            /* Make sure that it is a string value */
            let stringValue = "\(value)"
            
            /* Escape it */
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            
            /* Append it */
            urlVars += [key + "=" + "\(escapedValue!)"]
            
        }
        
        return (!urlVars.isEmpty ? "?" : "") + urlVars.joinWithSeparator("&")
    }
    
    class func sharedInstance() -> RESTClient {
        
        struct Singleton {
            static var sharedInstance = RESTClient()
        }
        
        return Singleton.sharedInstance
    }
}
