//
//  ViewController.swift
//  VirtualTourist
//
//  Created by Wouter de Vos on 2016/01/27.
//  Copyright © 2016 Wouter. All rights reserved.
//

import UIKit
import MapKit

class TravelLocationsMapViewController: UIViewController, MKMapViewDelegate {

    var longPressGestureRecognizer: UILongPressGestureRecognizer? = nil
    var currentAnnotation: Annotation? = nil
    var pins = [Pin]()
    
    @IBOutlet var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: "addPin:")
        mapView.addGestureRecognizer(longPressGestureRecognizer!)
        mapView.delegate = self
        
        fetchPins()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showPhotoAlbumViewController" {
            let photoAlbumViewController = segue.destinationViewController as! PhotoAlbumViewController
            let pin = sender as! Pin
            photoAlbumViewController.pin = pin
        }
    }
    
    // MARK: Fetch the pins for the map.
    
    func fetchPins() {
        for pin in pins {
            let annotation = Annotation(pin: pin)
            mapView.addAnnotation(annotation)
        }
    }
    
    // MARK: Add pins to the map. Used by the UILongPressGestureRecognizer
    
    func addPin(recognizer: UILongPressGestureRecognizer) {
        // Get the touch point from the UILongPressGestureRecognizer and convert it to coordinates on the map view.
        let point: CGPoint = recognizer.locationInView(mapView)
        let coordinate: CLLocationCoordinate2D = mapView.convertPoint(point, toCoordinateFromView: mapView)
        
        switch recognizer.state {
        case .Began:
            // Create a new Pin for the point that was touched on the map.
            let pin = Pin(latitude: coordinate.latitude, longitude: coordinate.longitude, photos: [Photo]())
            currentAnnotation = Annotation(pin: pin)
            currentAnnotation?.coordinate = coordinate
            
            // Add the annotation to the map.
            mapView.addAnnotation(currentAnnotation!)
        case .Changed:
            currentAnnotation?.coordinate = coordinate
        case .Ended:
            pins.append(currentAnnotation!.pin)
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
        print("didSelectAnnotationView")
        mapView.deselectAnnotation(view.annotation!, animated: true)
        performSegueWithIdentifier("showPhotoAlbumViewController", sender: [Photo]())
    }
}

