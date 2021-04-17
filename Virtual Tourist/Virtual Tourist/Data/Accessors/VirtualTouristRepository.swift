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
    
    func fetchPhotos(forPin pin: Pin) -> Observable<[Photo]> {
        networkDataSource.fetchPhotos(forPin: pin).listenForChanges { [weak self] photos in
            self?.cachedDataSource.savePhotos(photos, forPin: pin)
        }
        
        return cachedDataSource.fetchPhotos(forPin: pin)
    }
}
