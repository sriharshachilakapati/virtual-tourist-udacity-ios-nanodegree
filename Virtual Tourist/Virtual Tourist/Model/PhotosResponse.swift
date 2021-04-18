//
//  PhotoResponse.swift
//  Virtual Tourist
//
//  Created by Sri Harsha Chilakapati on 18/04/21.
//

import Foundation

struct PhotosResponse: Codable {
    let photos: PhotoPage
    let stat: String
}

struct PhotoPage: Codable {
    let page: Int
    let pages: Int
    let perPage: Int
    let total: String
    
    let photo: [PhotoInfo]
    
    enum CodingKeys: String, CodingKey {
        case perPage = "perpage"
        case page
        case pages
        case total
        case photo
    }
}

struct PhotoInfo: Codable {
    let id: String
    let owner: String
    let secret: String
    let server: String
}
