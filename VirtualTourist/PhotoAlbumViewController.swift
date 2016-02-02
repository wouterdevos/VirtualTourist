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
    
    var pin: Pin
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
    }
    
    
}
