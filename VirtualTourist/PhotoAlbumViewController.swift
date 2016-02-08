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
    
    var pin: Pin!
    var screenSize: CGRect!
    var edgeInsets: UIEdgeInsets!
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        
        screenSize = UIScreen.mainScreen().bounds
        
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 0, bottom: 10, right: 0)
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
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        print("didSelectAnnotationView")
        mapView.deselectAnnotation(view.annotation!, animated: true)
        performSegueWithIdentifier("showPhotoAlbumViewController", sender: [Photo]())
    }
    
    // MARK: UICollectionViewDataSource methods.
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 12
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let photoCollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("PhotoCollectionViewCell", forIndexPath: indexPath) as! PhotoCollectionViewCell
        
        let 
        photoCollectionViewCell.backgroundColor = UIColor(colorLiteralRed: 255, green: 128, blue: 33, alpha: 255)
        
        return photoCollectionViewCell
    }
}
