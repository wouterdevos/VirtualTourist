//
//  Photo.swift
//  VirtualTourist
//
//  Created by Wouter de Vos on 2016/01/31.
//  Copyright © 2016 Wouter. All rights reserved.
//

import CoreData

class Photo: NSManagedObject {
    
    struct Keys {
        static let ID = "id"
        static let Title = "Title"
        static let URL = "url_m"
        static let Height = "height"
        static let Width = "width"
    }
    
    @NSManaged var id: String
    @NSManaged var title: String
    @NSManaged var url: String
    @NSManaged var height: String
    @NSManaged var width: String
    @NSManaged var pin: Pin?
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String:AnyObject], context: NSManagedObjectContext) {
        
        // Core Data
        let entity = NSEntityDescription.entityForName("Photo", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        // Initialise photo
        id = dictionary[Keys.ID] as! String
        title = dictionary[Keys.Title] as! String
        url = dictionary[Keys.URL] as! String
        height = dictionary[Keys.Height] as! String
        width = dictionary[Keys.Width] as! String
    }
}