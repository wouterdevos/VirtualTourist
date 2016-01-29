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
    
    func handleLongPress(recognizer: UILongPressGestureRecognizer) {
        // Get the touch point from the UILongPressGestureRecognizer and convert it to coordinates on the map view.
        let point: CGPoint = recognizer.locationInView(mapView)
        let coordinate: CLLocationCoordinate2D = mapView.convertPoint(point, toCoordinateFromView: mapView)
        
        switch recognizer.state {
            case .Began:
                // Create a new Pin for the point that was touched on the map.
                currentAnnotation = Annotation()
                currentAnnotation?.setCoordinate(coordinate)
                
                // Add the annotation to the map.
                dispatch_async(dispatch_get_main_queue(), {
                    self.mapView.addAnnotation(self.currentAnnotation!)
                })
            case .Changed:
                dispatch_async(dispatch_get_main_queue(), {
                    self.currentAnnotation?.setCoordinate(coordinate)
                })
            default:
                return
        }
    }
}

