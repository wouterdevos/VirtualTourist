//
//  ViewController.swift
//  VirtualTourist
//
//  Created by Wouter de Vos on 2016/01/27.
//  Copyright © 2016 Wouter. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class TravelLocationsMapViewController: UIViewController, MKMapViewDelegate, NSFetchedResultsControllerDelegate {

    let Region = "region"
    let RegionLatitude = "latitude"
    let RegionLongitude = "longitude"
    let RegionLatitudeDelta = "latitudeDelta"
    let RegionLongitudeDelta = "longitudeDelta"
    
    let ShowPhotoAlbumViewController = "showPhotoAlbumViewController"
    
    var longPressGestureRecognizer: UILongPressGestureRecognizer? = nil
    var currentPin: Pin? = nil
    var currentAnnotation: PinAnnotation? = nil
    var isDragging = false
    
    @IBOutlet var mapView: MKMapView!
    
    var context: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: "Pin")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "latitude", ascending: true)]
        
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: self.context,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        return fetchedResultsController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // This call is necessary to initialise the DataModel's observers.
        DataModel.sharedInstance()
        
        longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: "addPin:")
        mapView.addGestureRecognizer(longPressGestureRecognizer!)
        mapView.delegate = self
        fetchedResultsController.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        fetchPins()
        fetchRegion()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == ShowPhotoAlbumViewController {
            // Configure the back button.
            let backBarButtonItem = UIBarButtonItem()
            backBarButtonItem.title = "OK"
            navigationItem.backBarButtonItem = backBarButtonItem
            
            // Configure the photo album view controller.
            let photoAlbumViewController = segue.destinationViewController as! PhotoAlbumViewController
            let pin = sender as! Pin
            photoAlbumViewController.pin = pin
        }
    }
    
    // MARK: - Convenience method for saving the managed object context.
    
    func saveContext() {
        CoreDataStackManager.sharedInstance().saveContext()
    }
    
    // MARK: - Fetch the pins and the map region.
    
    func fetchPins() {
        do {
            try fetchedResultsController.performFetch()
        } catch {}
        
        let pins = fetchedResultsController.fetchedObjects as! [Pin]
        mapView.addAnnotations(createAnnotations(pins))
    }
    
    func fetchRegion() {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        guard let storedRegion = userDefaults.objectForKey(Region) as? [String:AnyObject] else {
            print("No region stored in user defaults")
            return
        }
        
        let latitude = storedRegion[RegionLatitude] as! CLLocationDegrees
        let longitude = storedRegion[RegionLongitude] as! CLLocationDegrees
        let latitudeDelta = storedRegion[RegionLatitudeDelta] as! CLLocationDegrees
        let longitudeDelta = storedRegion[RegionLongitudeDelta] as! CLLocationDegrees
        
        let center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let span = MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
        let region = MKCoordinateRegion(center: center, span: span)
        mapView.region = region
        mapView.setCenterCoordinate(center, animated: true)
    }
    
    // MARK: - Add pins to the map. Used by the UILongPressGestureRecognizer
    
    func addPin(recognizer: UILongPressGestureRecognizer) {
        // Get the touch point from the UILongPressGestureRecognizer and convert it to coordinates on the map view.
        let point: CGPoint = recognizer.locationInView(mapView)
        let coordinate: CLLocationCoordinate2D = mapView.convertPoint(point, toCoordinateFromView: mapView)
        
        switch recognizer.state {
        case .Began:
            // Create a new PinAnnotation for the point that was touched on the map.
            currentAnnotation = PinAnnotation()
            currentAnnotation!.coordinate = coordinate
            mapView.addAnnotation(currentAnnotation!)
        case .Changed:
            currentAnnotation!.coordinate = coordinate
        case .Ended:
            let latitude = currentAnnotation!.coordinate.latitude
            let longitude = currentAnnotation!.coordinate.longitude
            let pin = Pin(latitude: latitude, longitude: longitude, context: context)
            
            saveContext()
            currentAnnotation!.pin = pin
            
            let userInfo: [String:AnyObject] = ["pin": pin]
            NSNotificationCenter.defaultCenter().postNotificationName(DataModel.NotificationNames.SearchPhotos, object: nil, userInfo: userInfo)
        default:
            return
        }
    }
    
    // MARK: - Create annotations.
    
    func createAnnotations(pins: [Pin]) -> [PinAnnotation] {
        var annotations = [PinAnnotation]()
        
        for pin in pins {
            
            // Retrieve the latitude and longitude values
            let lat = CLLocationDegrees(pin.latitude)
            let long = CLLocationDegrees(pin.longitude)
            
            // The lat and long are used to create a CLLocationCoordinates2D instance.
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
            // Create the annotation and set its coordiate, title, and subtitle properties
            let annotation = PinAnnotation()
            annotation.coordinate = coordinate
            annotation.pin = pin
            
            // Place the annotation in an array of annotations.
            annotations.append(annotation)
        }
        
        return annotations
    }
    
    // MARK: - MKMapViewDelegate methods
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            // Create a new pin view and initialise it.
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.pinTintColor = MKPinAnnotationView.redPinColor()
            pinView!.draggable = true
            pinView!.animatesDrop = true
        }
        else {
            // Reuse an existing pin view and set the annotation.
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        mapView.deselectAnnotation(view.annotation!, animated: true)
        let annotation = view.annotation as! PinAnnotation
        performSegueWithIdentifier(ShowPhotoAlbumViewController, sender: annotation.pin!)
    }
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let region = [
            RegionLatitude: mapView.region.center.latitude,
            RegionLongitude: mapView.region.center.longitude,
            RegionLatitudeDelta: mapView.region.span.latitudeDelta,
            RegionLongitudeDelta: mapView.region.span.longitudeDelta
        ]
        NSUserDefaults.standardUserDefaults().setObject(region, forKey: Region)
    }
    
    // MARK: - NSFetchedResultsControllerDelegateMethods
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        switch(type) {
//        case .Insert:
//            if let pin = anObject as? Pin {
//                mapView.addAnnotation(anObject as! Pin)
//            }
//        case .Delete:
//            mapView.removeAnnotation(anObject as! Pin)
//        case .Update:
//            mapView.removeAnnotation(anObject as! Pin)
//            mapView.addAnnotation(anObject as! Pin)
        default:
            break
        }
    }
}

