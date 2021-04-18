//
//  NetworkDataSource.swift
//  Virtual Tourist
//
//  Created by Sri Harsha Chilakapati on 14/04/21.
//

import Foundation
import CoreLocation

class NetworkDataSource {
    private let getImagesForLocationApi = ApiDefinition<PhotosRequest, PhotosResponse>(
        url: "https://www.flickr.com/services/rest",
        method: .get
    )
    
    private let getImageDataApi = ApiDefinition<NilRequest, BinaryResponse>(
        url: "https://live.staticflickr.com/{server}/{id}_{secret}.jpg",
        method: .get
    )
    
    func fetchPhotos(forPin pin: Pin) -> Observable<[Data]> {
        let observable = Observable<[Data]>()
        let request = PhotosRequest(lat: pin.latitude, lon: pin.longitude)
        
        getImagesForLocationApi.call(withPayload: request) { result in
            switch (result) {
                case .failure(let error):
                    print(error)
                    
                case .success(let response):
                    self.fetchPhotos(response.photos.photo, observable: observable)
            }
        }
        
        return observable
    }
    
    private func fetchPhotos(_ photoInfos: [PhotoInfo], observable: Observable<[Data]>) {
        var numImagesFetched = 0
        var photos = [Data]()
        
        for photoInfo in photoInfos {
            getImageDataApi.call(withPathParameters: photoInfo) { result in
                numImagesFetched += 1
                
                switch (result) {
                    case .failure(let error):
                        print(error)
                        
                    case .success(let response):
                        photos.append(response.data)
                        
                        if numImagesFetched == photoInfos.count {
                            print("Downloaded \(numImagesFetched) images")
                            observable.dispatchChange(changed: photos)
                        }
                }
            }
        }
    }
}
