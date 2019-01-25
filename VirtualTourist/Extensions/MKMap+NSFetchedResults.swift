//
//  MKMap+NS.swift
//  VirtualTourist
//
//  Created by Lama on 14/01/2019.
//  Copyright © 2019 Lama. All rights reserved.
//

import UIKit
import MapKit
import CoreData


extension PhotoAlbumViewController : MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = false
            pinView!.pinTintColor = .red
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
}




extension PhotoAlbumViewController:NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            self.collectionView.insertItems(at: [newIndexPath!])
            
        case .delete:
            self.collectionView.deleteItems(at: [indexPath!])
        case .move:
            self.collectionView.moveItem(at: indexPath!, to: newIndexPath!)
        case .update:
            self.collectionView.reloadItems(at: [indexPath!])
        }
    }
    
}
