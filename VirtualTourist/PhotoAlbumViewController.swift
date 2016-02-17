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
    
    var pinAnnotation: PinAnnotation!
    var blockOperations: [NSBlockOperation] = []
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var newCollectionBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var messageLabel: UILabel!
    
    var context: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let pin = DataModel.fetchPin(self.pinAnnotation.createdAt!)!
        
        let fetchRequest = NSFetchRequest(entityName: "Photo")
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "pin == %@", pin)
        
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: self.context,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        return fetchedResultsController
    }()
    
    @IBAction func newCollection(sender: AnyObject) {
        DataModel.searchPhotos(pinAnnotation.createdAt!, isNewCollection: true)
        newCollectionBarButtonItem.enabled = false
        toggleMessageLabel(DownloadingMessage)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure the map view.
        let latitude = pinAnnotation.coordinate.latitude
        let longitude = pinAnnotation.coordinate.longitude
        
        let center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let span = MKCoordinateSpan(latitudeDelta: spanDelta, longitudeDelta: spanDelta)
        let region = MKCoordinateRegion(center: center, span: span)
        
        mapView.delegate = self
        mapView.zoomEnabled = false
        mapView.scrollEnabled = false
        mapView.pitchEnabled = false
        mapView.rotateEnabled = false
        mapView.addAnnotation(pinAnnotation)
        mapView.centerCoordinate = pinAnnotation.coordinate
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
        
        newCollectionBarButtonItem.enabled = false
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        addObservers()
        DataModel.searchPhotos(pinAnnotation.createdAt!, isNewCollection: false)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        // Remove notification observers.
        removeObservers()
    }
    
    // MARK: - Add and remove observers for NSNotifications.
    
    func addObservers() {
        defaultCenter.addObserver(self, selector: "searchPhotosStarted", name: DataModel.NotificationNames.SearchPhotosStarted, object: nil)
        defaultCenter.addObserver(self, selector: "searchPhotosPending", name: DataModel.NotificationNames.SearchPhotosPending, object: nil)
        defaultCenter.addObserver(self, selector: "searchPhotosCompleted", name: DataModel.NotificationNames.SearchPhotosCompleted, object: nil)
        defaultCenter.addObserver(self, selector: "photoDownloadCompleted", name: DataModel.NotificationNames.PhotoDownloadCompleted, object: nil)
        defaultCenter.addObserver(self, selector: "allPhotoDownloadsCompleted", name: DataModel.NotificationNames.AllPhotoDownloadsCompleted, object: nil)
    }
    
    func removeObservers() {
        defaultCenter.removeObserver(self, name: DataModel.NotificationNames.SearchPhotosStarted, object: nil)
        defaultCenter.removeObserver(self, name: DataModel.NotificationNames.SearchPhotosPending, object: nil)
        defaultCenter.removeObserver(self, name: DataModel.NotificationNames.SearchPhotosCompleted, object: nil)
        defaultCenter.removeObserver(self, name: DataModel.NotificationNames.SearchPhotosCompleted, object: nil)
        defaultCenter.removeObserver(self, name: DataModel.NotificationNames.PhotoDownloadCompleted, object: nil)
        defaultCenter.removeObserver(self, name: DataModel.NotificationNames.AllPhotoDownloadsCompleted, object: nil)
    }
    
    // MARK: - Fetch photos.
    
    func fetchPhotos() {
        toggleMessageLabel(DownloadingMessage)
        
        do {
            try fetchedResultsController.performFetch()
        } catch {}
    }
    
    // MARK: - Convenience method for saving the managed object context.
    
    func saveContext() {
        CoreDataStackManager.sharedInstance().saveContext()
    }
    
    // MARK: - NSNotification observer methods.
    
    func searchPhotosStarted() {
        dispatch_async(dispatch_get_main_queue()){
            self.toggleMessageLabel(self.DownloadingMessage)
        }
    }
    
    func searchPhotosPending() {
        dispatch_async(dispatch_get_main_queue()){
            self.toggleMessageLabel(self.DownloadingMessage)
        }
    }
    
    func searchPhotosCompleted() {
        dispatch_async(dispatch_get_main_queue()){
            self.fetchPhotos()
            self.collectionView.reloadData()
            let count = self.fetchedResultsController.fetchedObjects?.count ?? 0
            self.toggleMessageLabel(count == 0 ? self.NoImagesMessage : nil)
        }
    }
    
    func photoDownloadCompleted() {
        dispatch_async(dispatch_get_main_queue()){
            self.collectionView.reloadData()
        }
    }
    
    func allPhotoDownloadsCompleted() {
        dispatch_async(dispatch_get_main_queue()){
            self.newCollectionBarButtonItem.enabled = true
        }
    }
    
    // MARK: - Toggle the message label.
    
    func toggleMessageLabel(message: String?) {
        collectionView.hidden = message != nil
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
