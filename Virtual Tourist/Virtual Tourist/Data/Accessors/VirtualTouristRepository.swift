//
//  VirtualTouristRepository.swift
//  Virtual Tourist
//
//  Created by Sri Harsha Chilakapati on 14/04/21.
//

import Foundation
import CoreLocation

class VirtualTouristRepository {
    let networkDataSource = NetworkDataSource()
    let cachedDataSource = CachedDataSource()
    
    func fetchPins() -> Observable<[Pin]> {
        return cachedDataSource.fetchPins()
    }
    
    func addPin(at location: CLLocationCoordinate2D) {
        cachedDataSource.addPin(at: location)
    }
    
    func fetchPhotos(forPin pin: Pin, forceFetch: Bool) -> (Observable<[Photo]>, Bool) {
        let observable = cachedDataSource.fetchPhotos(forPin: pin)
        let fetchingImages = forceFetch || (cachedDataSource.getPhotoCount(for: pin) == 0)
        
        if fetchingImages {
            downloadPhotos(forPin: pin)
        }
        
        return (observable, fetchingImages)
    }
    
    func deletePhoto(_ photo: Photo) {
        cachedDataSource.deletePhoto(photo)
    }
    
    private func downloadPhotos(forPin pin: Pin) {
        networkDataSource.fetchPhotos(forPin: pin).listenOnce { photos in
            DispatchQueue.main.async {
                print("Saving \(photos.count) photos")
                self.cachedDataSource.savePhotos(photos, forPin: pin)
            }
        }
    }
}
