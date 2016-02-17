//
//  PhotosMetaData.swift
//  VirtualTourist
//
//  Created by Wouter de Vos on 2016/02/16.
//  Copyright © 2016 Wouter. All rights reserved.
//

import CoreData

class PhotosMetaData: NSManagedObject {
    
    struct Keys {
        static let Page = "page"
        static let PerPage = "perpage"
        static let Pages = "pages"
        static let Total = "total"
    }
    
    @NSManaged var page: NSNumber
    @NSManaged var perPage: NSNumber
    @NSManaged var pages: NSNumber
    @NSManaged var total: String
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String:AnyObject], context: NSManagedObjectContext) {
        
        let entity = NSEntityDescription.entityForName("PhotosMetaData", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        page = dictionary[Keys.Page] as! NSNumber
        perPage = dictionary[Keys.PerPage] as! NSNumber
        pages = dictionary[Keys.Pages] as! NSNumber
        total = dictionary[Keys.Total] as! String
    }
    
    func getTotal() -> NSNumber {
        return NSNumber(integer: Int(total)!)
    }
}
