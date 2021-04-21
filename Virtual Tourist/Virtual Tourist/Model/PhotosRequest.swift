//
//  PhotosRequest.swift
//  Virtual Tourist
//
//  Created by Sri Harsha Chilakapati on 18/04/21.
//

import Foundation

struct PhotosRequest: Encodable {
    let method = "flickr.photos.search"
    let apiKey = "<INSERT-API-KEY-HERE>"
    let format = "json"
    let perPage = 25
    let noJsonCallback = 1
    
    let lat: Double
    let lon: Double
    let page: Int
    
    enum CodingKeys: String, CodingKey {
        case method
        case apiKey = "api_key"
        case noJsonCallback = "nojsoncallback"
        case perPage = "per_page"
        case format
        case lat
        case lon
        case page
    }
}
