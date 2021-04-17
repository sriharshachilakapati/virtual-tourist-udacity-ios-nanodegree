//
//  CachedDataSource.swift
//  Virtual Tourist
//
//  Created by Sri Harsha Chilakapati on 14/04/21.
//

import CoreLocation
import CoreData
import UIKit

class CachedDataSource {
    func fetchPins() -> Observable<[Pin]> {
        let fetchRequest = NSFetchRequest<Pin>(entityName: "Pin")
        return ObservableFetchRequest(fetchRequest: fetchRequest)
    }
    
    func addPin(at location: CLLocationCoordinate2D) {
        let pin = Pin(context: (UIApplication.shared.delegate as! AppDelegate).backgroundContext)
        pin.latitude = location.latitude
        pin.longitude = location.longitude
        
        let _ = try? pin.managedObjectContext?.save()
    }
    
    func fetchPhotos(forPin pin: Pin) -> Observable<[Photo]> {
        let fetchRequest = NSFetchRequest<Photo>(entityName: "Photo")
        fetchRequest.predicate = NSPredicate(format: "pin == %@", pin)
        
        return ObservableFetchRequest(fetchRequest: fetchRequest)
    }
    
    func savePhotos(_ photos: [Photo], forPin pin: Pin) {
        // TODO: Write to DB
    }
}
