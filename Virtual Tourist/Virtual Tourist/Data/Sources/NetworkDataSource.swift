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
    
    func fetchPhotoInfos(forPin pin: Pin) -> Observable<[PhotoInfo]> {
        let observable = Observable<[PhotoInfo]>()
        let request = PhotosRequest(lat: pin.latitude, lon: pin.longitude)
        
        getImagesForLocationApi.call(withPayload: request) { result in
            switch result {
                case .failure(let error):
                    observable.dispatchChange(changed: [])
                    print(error)
                    
                case .success(let response):
                    observable.dispatchChange(changed: response.photos.photo)
            }
        }
        
        return observable
    }
    
    func fetchPhoto(info: PhotoInfo, completion: @escaping (Data?) -> Void) {
        getImageDataApi.call(withPathParameters: info) { result in
            switch result {
                case .failure(let error):
                    print(error)
                    completion(nil)
                    
                case .success(let response):
                    completion(response.data)
            }
        }
    }
}
