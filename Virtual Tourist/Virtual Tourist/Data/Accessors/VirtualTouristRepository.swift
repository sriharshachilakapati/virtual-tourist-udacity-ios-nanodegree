//
//  VirtualTouristRepository.swift
//  Virtual Tourist
//
//  Created by Sri Harsha Chilakapati on 14/04/21.
//

import Foundation
import CoreLocation

typealias PhotoFetchProgress = (photos: [Photo], totalCount: Int)

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
        return Observable<[Photo]>.map(source: cachedDataSource.fetchPhotos(forPin: pin)) { photos in (photos, photos.count) }
    }
    
    private func fetchPhotosFromNetwork(for pin: Pin) -> Observable<PhotoFetchProgress> {
        cachedDataSource.clearPhotos(for: pin)
        
        let cachedPhotosObservable = self.cachedDataSource.fetchPhotos(forPin: pin)
        let observable = Observable<PhotoFetchProgress>(livingAlongWith: cachedPhotosObservable)
        
        networkDataSource.fetchPhotoInfos(forPin: pin).listenOnce { photoInfos in
            // If there are no photos in server
            if photoInfos.count == 0 {
                observable.dispatchChange(changed: (photos: [], totalCount: 0))
            }
            
            var numFailed = 0
            var isFinished = false
            
            // Setup an observable from cache. Using weak ref for observable because it has to die
            // when reference to observable goes into the void of ARC.
            cachedPhotosObservable.listenForChanges { [weak observable] photos in
                isFinished = isFinished || photoInfos.count == (numFailed + photos.count)
                let totalCount = isFinished ? photos.count : photoInfos.count - numFailed
                
                observable?.dispatchChange(changed: (photos: photos, totalCount: totalCount))
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
