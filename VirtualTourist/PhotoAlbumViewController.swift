//
//  PhotoAlbumViewController.swift
//  VirtualTourist
//
//  Created by Wouter de Vos on 2016/01/30.
//  Copyright © 2016 Wouter. All rights reserved.
//

import UIKit
import MapKit

class PhotoAlbumViewController: UIViewController, MKMapViewDelegate {
    
    var pin: Pin!
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
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
