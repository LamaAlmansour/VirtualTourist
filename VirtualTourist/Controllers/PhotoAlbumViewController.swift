//
//  PhotoAlbumViewController.swift
//  VirtualTourist
//
//  Created by Lama on 11/01/2019.
//  Copyright © 2019 Lama. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PhotoAlbumViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var toolBar: UIBarButtonItem!
    
    var pin: Pin!
    var dataController: DataController!
    var fetchedResultsController: NSFetchedResultsController<Photo>!
    var selectedPhotos: [IndexPath]! = []

    
    override func viewDidLoad() {
        super.viewDidLoad()

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        dataController = appDelegate.dataController

        collectionView.allowsMultipleSelection = true
        
        setDelegateAndDataSource()
        createAnnotation()
        setupFetchedResultsController()
        
        if fetchedResultsController.fetchedObjects!.count == 0 {
            loadPhotos()
    }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView?.reloadData()
    }
    
    
    func setDelegateAndDataSource() {
        mapView.delegate = self
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    func createAnnotation(){
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2DMake(pin.latitude, pin.longitude)
        mapView.addAnnotation(annotation)
        
        let coredinate:CLLocationCoordinate2D = CLLocationCoordinate2DMake(pin.latitude, pin.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        let region = MKCoordinateRegion(center: coredinate, span: span)
        
        mapView.setRegion(region, animated: true)
    }
    
    
    func setupFetchedResultsController() {
        
        let fetchRequest:NSFetchRequest<Photo> = Photo.fetchRequest()
        let predicate = NSPredicate(format: "pin == %@", pin)
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = []
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self as NSFetchedResultsControllerDelegate
        do{
            try fetchedResultsController.performFetch()
        }catch{
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
        
    }
    
    
    
    func loadPhotos() {
        toolBar.isEnabled = false
        let flickrCall = API.sharedInstance
        
        flickrCall.getPhotosforLocation(pin.latitude, pin.longitude, 20) { (success, photos) in
            
            if success == false {
                print("Unable to download images from Flickr.")
                return
            }
            
            if photos!.count == 0 {
                self.displayAlert(message: "This location contains no images.", title: "Sorry,", vc: self)
            }
            
            photos!.forEach() { photo_url in
                let photo = Photo(context: self.dataController.viewContext)
                photo.url = URL(string: photo_url["url_m"] as! String)?.absoluteString
                photo.pin = self.pin
                
                do {
                    try self.dataController.viewContext.save()
                } catch  {
                    print(error.localizedDescription)
                }
            }
            self.toolBar.isEnabled = true

        }
    }
    
    
    
    func downloadImage( imagePath:String, completionHandler: @escaping (_ imageData: Data?, _ errorString: String?) -> Void){
        
        // Create session and request
        let session = URLSession.shared
        let imgURL = NSURL(string: imagePath)
        let request: NSURLRequest = NSURLRequest(url: imgURL! as URL)
        
        // Create network request
        let task = session.dataTask(with: request as URLRequest) {data, response, downloadError in
            
            if downloadError != nil {
                completionHandler(nil, "Could not download image \(imagePath)")
            } else {
                
                completionHandler(data, nil)
            }
        }
        task.resume()
    }
    
    
    // MARK: Refresh New Collection
    
    
    @IBAction func updateCollection(_ sender: Any) {
        if hasSelectedPhotos() {
            deleteSelectedPhotos()
        } else {
            fetchedResultsController.fetchedObjects?.forEach() { photo in
                dataController.viewContext.delete(photo)
                do {
                    try dataController.viewContext.save()
                } catch {
                    print("Unable to delete photo. \(error.localizedDescription)")
                }
            }
            loadPhotos()
            self.collectionView.reloadData()
        }
    }
    
    func displayAlert(message: String, title: String, vc: UIViewController)
    {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let OKAction = UIAlertAction(title: "ok", style: .default, handler: nil)
        alertController.addAction(OKAction)
        
        vc.present(alertController, animated: true, completion: nil)
    }
    
}
