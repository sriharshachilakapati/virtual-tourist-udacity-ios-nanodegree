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
    
    func fetchPhotos(forPin pin: Pin, forceFetch: Bool) -> Observable<[Photo]> {
        let observable = cachedDataSource.fetchPhotos(forPin: pin)
        
        if forceFetch {
            downloadPhotos(forPin: pin)
        } else {
            observable.listenOnce { photos in
                if photos.count == 0 {
                    self.downloadPhotos(forPin: pin)
                }
            }
        }
        
        return observable
    }
    
    private func downloadPhotos(forPin pin: Pin) {
        networkDataSource.fetchPhotos(forPin: pin).listenOnce { photos in
            DispatchQueue.main.async {
                self.cachedDataSource.savePhotos(photos, forPin: pin)
            }
        }
    }
}
