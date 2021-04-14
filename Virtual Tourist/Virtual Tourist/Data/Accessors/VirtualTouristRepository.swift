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
    
    func fetchPins() -> Observable<[Void]> {
        let cachedObservable = cachedDataSource.fetchPins()
        
        networkDataSource.fetchPins().listenForChanges { [weak self] pins in
            self?.cachedDataSource.savePins(pins)
            cachedObservable.dispatchChange(changed: pins)
        }
        
        return cachedObservable
    }
    
    func fetchPhotos(location: CLLocationCoordinate2D) -> Observable<[Void]> {
        let cachedObservable = cachedDataSource.fetchPhotos(location: location)
        
        networkDataSource.fetchPhotos(location: location).listenForChanges { [weak self] photos in
            self?.cachedDataSource.savePhotos(photos)
            cachedObservable.dispatchChange(changed: photos)
        }
        
        return cachedObservable
    }
}
