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

class PhotoAlbumViewController: UIViewController, MKMapViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, NSFetchedResultsControllerDelegate {
    
    let NoImagesMessage = "No Images"
    let DownloadingMessage = "Downloading..."
    
    let spanDelta = 0.03
    let defaultCenter = NSNotificationCenter.defaultCenter()
    
    var pin: Pin!
    var blockOperations: [NSBlockOperation] = []
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var newCollectionBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var messageLabel: UILabel!
    
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
    
    @IBAction func newCollection(sender: AnyObject) {
        // Delete all photos for this pin and save the context.
        var page = pin.page.intValue
        pin.page = NSNumber(int: ++page)
        for photo in fetchedResultsController.fetchedObjects! as! [Photo] {
            context.deleteObject(photo)
        }
        saveContext()
        
        // Send a notification to download a
        let userInfo: [String:AnyObject] = ["pin": pin!]
        NSNotificationCenter.defaultCenter().postNotificationName(DataModel.NotificationNames.SearchPhotos, object: nil, userInfo: userInfo)
        
       toggleMessageLabel(DownloadingMessage)
    }
    
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
        collectionView.delegate = self
        collectionView.setCollectionViewLayout(layout, animated: true)
        
        fetchedResultsController.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        // Add notification observers.
        addObservers()
        
        fetchPhotos()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        // Remove notification observers.
        removeObservers()
    }
    
    // MARK: - Add and remove observers for NSNotifications.
    
    func addObservers() {
        defaultCenter.addObserver(self, selector: "searchPhotosCompleted", name: DataModel.NotificationNames.SearchPhotosCompleted, object: nil)
        defaultCenter.addObserver(self, selector: "photoDownloadCompleted", name: DataModel.NotificationNames.PhotoDownloadCompleted, object: nil)
    }
    
    func removeObservers() {
        defaultCenter.removeObserver(self, name: DataModel.NotificationNames.SearchPhotosCompleted, object: nil)
        defaultCenter.removeObserver(self, name: DataModel.NotificationNames.PhotoDownloadCompleted, object: nil)
    }
    
    // MARK: - Fetch photos
    
    func fetchPhotos() {
        do {
            try fetchedResultsController.performFetch()
        } catch {}
    }
    
    // MARK: - Convenience method for saving the managed object context.
    
    func saveContext() {
        CoreDataStackManager.sharedInstance().saveContext()
    }
    
    // MARK: - NSNotification observer methods
    
    func searchPhotosCompleted() {
        dispatch_async(dispatch_get_main_queue()){
            let count = self.pin.photos.count
            self.toggleMessageLabel(count == 0 ? self.NoImagesMessage : nil)
            self.fetchPhotos()
            self.collectionView.reloadData()
        }
    }
    
    func photoDownloadCompleted() {
        dispatch_async(dispatch_get_main_queue()){
            self.collectionView.reloadData()
        }
    }
    
    // MARK: - Toggle the message label.
    
    func toggleMessageLabel(message: String?) {
        messageLabel.hidden = message == nil
        if let message = message {
            messageLabel.text = message
        }
    }
    
    // MARK: - MKMapViewDelegate methods.
    
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
    
    // MARK: - UICollectionViewDataSource methods.
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let photoCollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("PhotoCollectionViewCell", forIndexPath: indexPath) as! PhotoCollectionViewCell
        let photo = fetchedResultsController.objectAtIndexPath(indexPath) as! Photo
        
        configureCell(photoCollectionViewCell, photo: photo)
        
        return photoCollectionViewCell
    }
    
    // MARK: - UICollectionViewDelegate methods.
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let photo = fetchedResultsController.objectAtIndexPath(indexPath) as! Photo
        context.deleteObject(photo)
        saveContext()
    }
    
    // MARK: - Configure Cell
    
    func configureCell(cell: PhotoCollectionViewCell, photo: Photo) {
        var photoImage = UIImage(named: "placeholder")
        
        cell.photoImageView.image = nil
        
        // Set the Photo image
        if photo.image != nil {
            photoImage = photo.image!
        }
        
        cell.photoImageView.image = photoImage
    }
    
    // MARK: NSFetchedResultsControllerDelegateMethods
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        blockOperations.removeAll(keepCapacity: false)
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        
        switch type {
        case .Insert:
            blockOperations.append(
                NSBlockOperation(block: { [weak self] in
                    if let this = self {
                        this.collectionView!.insertSections(NSIndexSet(index: sectionIndex))
                    }
                    })
            )
        case .Delete:
            blockOperations.append(
                NSBlockOperation(block: { [weak self] in
                    if let this = self {
                        this.collectionView!.deleteSections(NSIndexSet(index: sectionIndex))
                    }
                })
            )
        default:
            blockOperations.append(
                NSBlockOperation(block: { [weak self] in
                        if let this = self {
                            this.collectionView!.reloadSections(NSIndexSet(index: sectionIndex))
                        }
                    })
            )
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        switch type {
        case .Insert:
            blockOperations.append(
                NSBlockOperation(block: { [weak self] in
                        if let this = self {
                            this.collectionView!.insertItemsAtIndexPaths([newIndexPath!])
                        }
                })
            )
        case .Delete:
            blockOperations.append(
                NSBlockOperation(block: { [weak self] in
                        if let this = self {
                            this.collectionView!.deleteItemsAtIndexPaths([indexPath!])
                        }
                })
            )
        case .Update:
            blockOperations.append(
                NSBlockOperation(block: { [weak self] in
                        if let this = self {
                            this.collectionView!.reloadItemsAtIndexPaths([indexPath!])
                        }
                    })
            )
        case .Move:
            blockOperations.append(
                NSBlockOperation(block: { [weak self] in
                        if let this = self {
                            this.collectionView!.moveItemAtIndexPath(indexPath!, toIndexPath: newIndexPath!)
                        }
                    })
            )
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        
        collectionView.performBatchUpdates({ () -> Void in
            for blockOperation in self.blockOperations {
                blockOperation.start()
            }
        }, completion: { (finished) -> Void in
            self.blockOperations.removeAll(keepCapacity: false)
        })
        
    }
}
