//
//  CachedDataSource.swift
//  Virtual Tourist
//
//  Created by Sri Harsha Chilakapati on 14/04/21.
//

import Foundation
import CoreLocation

class CachedDataSource {
    func fetchPins() -> Observable<[Void]> {
        fatalError()
    }
    
    func savePins(_ pins: [Void]) {
        // TODO: Write to the cached data store
    }
    
    func fetchPhotos(location: CLLocationCoordinate2D) -> Observable<[Void]> {
        fatalError()
    }
    
    func savePhotos(_ photos: [Void]) {
        // TODO: Write to the cached data store
    }
}
