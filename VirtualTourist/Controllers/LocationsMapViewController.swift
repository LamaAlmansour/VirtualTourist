//
//  ViewController.swift
//  VirtualTourist
//
//  Created by Lama on 11/01/2019.
//  Copyright © 2019 Lama. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class LocationsMapViewController: UIViewController  {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var dataController: DataController!
    var api: API!
    var fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
    var pin: Pin!

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpMap()
        setupFetchedResultsController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupFetchedResultsController()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        //Make The center of the map and the zoom level persistent
        let defaults = UserDefaults.standard
        defaults.setValue(mapView.centerCoordinate.latitude, forKey: "lat")
        defaults.setValue(mapView.centerCoordinate.longitude, forKey: "long")
        defaults.setValue(mapView.region.span.latitudeDelta, forKey: "latDelta")
        defaults.setValue(mapView.region.span.longitudeDelta, forKey: "longDelta")

    }
    
    func setUpMap(){
        
        mapView.delegate = self
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action:#selector(self.longPressed(sender:)))
        self.mapView.addGestureRecognizer(longPressRecognizer)
        
        let defaults = UserDefaults.standard
        if  let lat = defaults.value(forKey: "lat"),
            let long = defaults.value(forKey: "long"),
            let latDelta = defaults.value(forKey: "latDelta"),
            let longDelta = defaults.value(forKey: "longDelta") {
            let center: CLLocationCoordinate2D = CLLocationCoordinate2DMake(lat as! Double, long as! Double)
            let span: MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: latDelta as! Double, longitudeDelta: longDelta as! Double)
            let region: MKCoordinateRegion = MKCoordinateRegion(center: center, span: span)
            mapView.setRegion(region, animated: true)
        }
    }
    
    @objc func longPressed(sender: UILongPressGestureRecognizer)
    {
        if sender.state == .began {

        let location = sender.location(in: self.mapView)
        let locationCoor = self.mapView.convert(location, toCoordinateFrom: mapView)
        let annotation = MKPointAnnotation()
        
        annotation.coordinate = locationCoor
        mapView.addAnnotation(annotation)
        print("new pin added")
        persistNewPin(location: locationCoor)
        }
    }
    
    func persistNewPin(location: CLLocationCoordinate2D){
        let newPin = Pin(context: dataController.viewContext)
        newPin.latitude = location.latitude
        newPin.longitude = location.longitude
        do{
            try dataController.viewContext.save()
            print("Success Persist New pin")
            pin = newPin
        } catch{
            print("Persist New Pin Error")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPhotos"{
            let vc = segue.destination as! PhotoAlbumViewController
            vc.pin = pin
        }
    }
    
    func setupFetchedResultsController() {
        if let result = try? dataController.viewContext.fetch(fetchRequest) {
            for pin in result {
                let annotation = MKPointAnnotation()
                annotation.coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(pin.latitude), longitude: CLLocationDegrees(pin.longitude))
                mapView.addAnnotation(annotation)
            }
        }
    }

}

