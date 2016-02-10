//
//  PhotoAlbumViewController.swift
//  VirtualTourist
//
//  Created by Wouter de Vos on 2016/01/30.
//  Copyright © 2016 Wouter. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PhotoAlbumViewController: UIViewController, MKMapViewDelegate, UICollectionViewDataSource, NSFetchedResultsControllerDelegate {
    
    let spanDelta = 0.03
    
    var pin: Pin!
    var insertedIndexPaths: [NSIndexPath]!
    var deletedIndexPaths: [NSIndexPath]!
    var updatedIndexPaths: [NSIndexPath]!
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var context: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: "Photo")
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "pin == %@", self.pin)
        
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: self.context,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        return fetchedResultsController
    }()
    
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
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
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
    
    // MARK: NSFetchedResultsControllerDelegateMethods
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        insertedIndexPaths = [NSIndexPath]()
        deletedIndexPaths = [NSIndexPath]()
        updatedIndexPaths = [NSIndexPath]()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        switch type {
        case .Insert:
            insertedIndexPaths.append(newIndexPath!)
            break
        case .Delete:
            deletedIndexPaths.append(indexPath!)
            break
        case .Update:
            updatedIndexPaths.append(indexPath!)
        default:
            break
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        
        for i in insertedIndexPaths {
            let pin: AnyObject? = fetchedResultsController.fetchedObjects?[i.row]
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2DMake(pin!.latitude as Double, pin!.longitude as Double)
            annotation.pin = fetchedResultsController.objectAtIndexPath(i) as! Pin
            mapView.addAnnotation(annotation)
        }
        
        for i in deletedIndexPaths {
            let pin: AnyObject? = fetchedResultsController.fetchedObjects?[i.row]
            let annotation = annotationForPin(pin)
            mapView.removeAnnotation(annotation)
        }
        
        for i in updatedIndexPaths {
            var pin: AnyObject? = fetchedResultsController.fetchedObjects?[i.row]
            annotationForPin(pin).coordinate = CLLocationCoordinate2DMake(pin!.latitude as Double, pin!.longitude as Double)
        }
        
    }
}
