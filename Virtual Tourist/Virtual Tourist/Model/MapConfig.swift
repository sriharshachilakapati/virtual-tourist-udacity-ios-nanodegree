//
//  MapConfig.swift
//  Virtual Tourist
//
//  Created by Sri Harsha Chilakapati on 21/04/21.
//

import Foundation

struct MapConfig: Codable {
    var latitude: Double = 0
    var longitude: Double = 0
    var latitudeSpan: Double = 0
    var longitudeSpan: Double = 0
    
    func save() {
        let data = try! JSONEncoder().encode(self)
        UserDefaults.standard.setValue(data, forKey: String(describing: self))
        UserDefaults.standard.synchronize()
    }
    
    mutating func load() -> Bool {
        guard let data = UserDefaults.standard.value(forKey: String(describing: self)) else { return false }
        self = try! JSONDecoder().decode(MapConfig.self, from: data as! Data)
        return true
    }
}
