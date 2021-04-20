//
//  VirtualTouristRepository.swift
//  Virtual Tourist
//
//  Created by Sri Harsha Chilakapati on 14/04/21.
//

import Foundation
import CoreLocation

typealias PhotoFetchProgress = (photos: [Photo], didFetchFinish: Bool)

class VirtualTouristRepository {
    let networkDataSource = NetworkDataSource()
    let cachedDataSource = CachedDataSource()
    
    func fetchPins() -> Observable<[Pin]> {
        return cachedDataSource.fetchPins()
    }
    
    func addPin(at location: CLLocationCoordinate2D) {
        cachedDataSource.addPin(at: location)
    }
    
    func fetchPhotos(for pin: Pin, forceFetch: Bool) -> Observable<PhotoFetchProgress> {
        let shouldFetchFromNetwork = forceFetch || (cachedDataSource.getPhotoCount(for: pin) == 0)
        
        if shouldFetchFromNetwork {
            return fetchPhotosFromNetwork(for: pin)
        }
        
        return fetchPhotosFromCache(for: pin)
    }
    
    private func fetchPhotosFromCache(for pin: Pin) -> Observable<PhotoFetchProgress> {
        return cachedDataSource.fetchPhotos(forPin: pin).map { photos in (photos, true) }
    }
    
    private func fetchPhotosFromNetwork(for pin: Pin) -> Observable<PhotoFetchProgress> {
        cachedDataSource.clearPhotos(for: pin)
        
        let cachedPhotosObservable = self.cachedDataSource.fetchPhotos(forPin: pin)
        let observable = Observable<PhotoFetchProgress>(livingAlongWith: cachedPhotosObservable)
        
        networkDataSource.fetchPhotoInfos(forPin: pin).listenOnce { photoInfos in
            // If there are no photos in server
            if photoInfos.count == 0 {
                observable.dispatchChange(changed: (photos: [], didFetchFinish: true))
            }
            
            var numFailed = 0
            
            // Setup an observable from cache
            cachedPhotosObservable.listenForChanges { photos in
                let isFinished = photoInfos.count == (numFailed + photos.count)
                observable.dispatchChange(changed: (photos: photos, didFetchFinish: isFinished))
            }
            
            // Start downloading photos
            for photoInfo in photoInfos {
                self.networkDataSource.fetchPhoto(info: photoInfo) { data in
                    guard let data = data else { numFailed += 1; return }
                    self.cachedDataSource.savePhoto(data: data, for: pin)
                }
            }
        }
        
        return observable
    }
    
    func deletePhoto(_ photo: Photo) {
        cachedDataSource.deletePhoto(photo)
    }
}
