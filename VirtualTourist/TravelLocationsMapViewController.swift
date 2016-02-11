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
    var pins = [Pin]()
    
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
        
        longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: "addPin:")
        mapView.addGestureRecognizer(longPressGestureRecognizer!)
        mapView.delegate = self
        fetchedResultsController.delegate = self
        
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
    
    // MARK: Fetch the pins and the map region.
    
    func fetchPins() {
        do {
            try fetchedResultsController.performFetch()
        } catch {}
        
        mapView.addAnnotations(fetchedResultsController.fetchedObjects as! [Pin])
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
    
    // MARK: Convenience method for saving the managed object context.
    
    func saveContext() {
        CoreDataStackManager.sharedInstance().saveContext()
    }
    
    // MARK: Add pins to the map. Used by the UILongPressGestureRecognizer
    
    func addPin(recognizer: UILongPressGestureRecognizer) {
        // Get the touch point from the UILongPressGestureRecognizer and convert it to coordinates on the map view.
        let point: CGPoint = recognizer.locationInView(mapView)
        let coordinate: CLLocationCoordinate2D = mapView.convertPoint(point, toCoordinateFromView: mapView)
        
        switch recognizer.state {
        case .Began:
            // Create a new Pin for the point that was touched on the map.
            let pin = Pin(latitude: coordinate.latitude, longitude: coordinate.longitude, context: context)
            currentPin = pin
        case .Changed:
            currentPin?.latitude = coordinate.latitude
            currentPin?.longitude = coordinate.longitude
        case .Ended:
            let userInfo: [String:AnyObject] = ["pin": currentPin!]
            NSNotificationCenter.defaultCenter().postNotificationName(DataModel.NotificationNames.SearchPhotos, object: nil, userInfo: userInfo)
            saveContext()
        default:
            return
        }
    }
    
    // MARK: MKMapViewDelegate methods
    
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
        let pin = view.annotation as! Pin
        performSegueWithIdentifier(ShowPhotoAlbumViewController, sender: pin)
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
    
    // MARK: NSFetchedResultsControllerDelegateMethods
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        switch(type) {
        case .Insert:
            mapView.addAnnotation(anObject as! Pin)
        case .Delete:
            mapView.removeAnnotation(anObject as! Pin)
        case .Update:
            mapView.removeAnnotation(anObject as! Pin)
            mapView.addAnnotation(anObject as! Pin)
        default:
            break
        }
    }
}

