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
    var annotations = [MKAnnotation]()
    
    @IBOutlet var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: "handleLongPress:")
        mapView.addGestureRecognizer(longPressGestureRecognizer!)
        mapView.delegate = self
        mapView.addAnnotations(annotations)
    }

    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            // Create a new pin view and initialise it.
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = MKPinAnnotationView.redPinColor()
            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        }
        else {
            // Reuse an existing pin view and set the annotation.
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            //TODO: Segue to the collection view
            
        }
    }
    
    func handleLongPress(recognizer: UILongPressGestureRecognizer) {
        
        // Get the touch point from the UILongPressGestureRecognizer and convert it to coordinates on the map view.
        let point: CGPoint = recognizer.locationInView(mapView)
        let coordinate: CLLocationCoordinate2D = mapView.convertPoint(point, toCoordinateFromView: mapView)
        
        // Create a new MKPointAnnotation for the pin that was dropped on the map.
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        
        // Place the annotation in an array of annotations.
        annotations.append(annotation)
        
        // Add the annotations to the map.
        mapView.addAnnotations(annotations)
    }
}

