//
//  collectionViewExt.swift
//  VirtualTourist
//
//  Created by Lama on 14/01/2019.
//  Copyright © 2019 Lama. All rights reserved.
//


import Foundation
import UIKit


extension PhotoAlbumViewController: UICollectionViewDelegate , UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return fetchedResultsController.fetchedObjects!.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! photoCell
        
        let photo = fetchedResultsController.object(at: indexPath)
        
        if let data = photo.data {
            cell.img.image = UIImage(data: data)
        } else {
            cell.img.image = UIImage(named: "image")
            cell.contentView.alpha = 1.0
            
            downloadImage(imagePath: photo.url!) { imageData, errorString in
                if let imageData = imageData {
                    DispatchQueue.main.async {
                        cell.img.image = UIImage(data: imageData)
                    }
                    photo.data = imageData
                    try? self.dataController.viewContext.save()
                }
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.contentView.alpha = 0.4
        
        if selectedPhotos.contains(indexPath) == false {
            selectedPhotos.append(indexPath)
        }
        selectPhotoActionButton()
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.contentView.alpha = 1.0
        
        if let index = selectedPhotos.firstIndex(of: indexPath) {
            selectedPhotos.remove(at: index)
        }
        selectPhotoActionButton()
    }
    
    
    func selectPhotoActionButton() {
        if hasSelectedPhotos() {
            toolBar.title = "Delete Selected Photos"
            toolBar.tintColor = .red
        }
        else {
            toolBar.title = "Update Collection"
        }
    }
    
    func hasSelectedPhotos() -> Bool {
        if selectedPhotos.count == 0 {
            return false
        }
        return true
    }
    
    func deleteSelectedPhotos() {
        let photos = selectedPhotos.map() { fetchedResultsController.object(at: $0) }
        photos.forEach() { photo in
            dataController.viewContext.delete(photo)
            try? dataController.viewContext.save()
        }
        
        selectedPhotos.removeAll()
        selectPhotoActionButton()
    }
}

