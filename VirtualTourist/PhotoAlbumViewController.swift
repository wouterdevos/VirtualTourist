//
//  PhotoAlbumViewController.swift
//  VirtualTourist
//
//  Created by Wouter de Vos on 2016/01/30.
//  Copyright © 2016 Wouter. All rights reserved.
//

import UIKit
import MapKit

class PhotoAlbumViewController: UIViewController, MKMapViewDelegate, UICollectionViewDataSource {
    
    let spanDelta = 0.03
    
    var pin: Pin!
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure the map view.
        let latitude = Double(pin.latitude)
        let longitude = Double(pin.longitude)
        let center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let span = MKCoordinateSpan(latitudeDelta: spanDelta, longitudeDelta: spanDelta)
        let region = MKCoordinateRegion(center: center, span: span)
        
        mapView.delegate = self
        mapView.zoomEnabled = false
        mapView.scrollEnabled = false
        mapView.pitchEnabled = false
        mapView.rotateEnabled = false
        mapView.addAnnotation(pin)
        mapView.centerCoordinate = pin.coordinate
        mapView.region = region
        
        // Configure the collection view.
        let screenSize = UIScreen.mainScreen().bounds
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.itemSize = CGSize(width: screenSize.width / 3, height: screenSize.width / 3)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        
        collectionView.dataSource = self
        collectionView.setCollectionViewLayout(layout, animated: true)
        collectionView.registerClass(PhotoCollectionViewCell.self, forCellWithReuseIdentifier: "PhotoCollectionViewCell")
    }
    
    // MARK: MKMapViewDelegate methods.
    
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
    
    // MARK: UICollectionViewDataSource methods.
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 12
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let photoCollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("PhotoCollectionViewCell", forIndexPath: indexPath) as! PhotoCollectionViewCell
        
        let red = randomColor()
        let green = randomColor()
        let blue = randomColor()
        photoCollectionViewCell.backgroundColor = UIColor(red: red, green: green, blue: blue, alpha: 1)
        
        return photoCollectionViewCell
    }
    
    func randomColor() -> CGFloat {
        let random = Double(arc4random() % 255) / 255.0
        return CGFloat(random)
    }
}
