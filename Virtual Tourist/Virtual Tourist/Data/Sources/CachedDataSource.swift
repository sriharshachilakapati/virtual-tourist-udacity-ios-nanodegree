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
    private lazy var context = (UIApplication.shared.delegate as! AppDelegate).backgroundContext
    
    func fetchPins() -> Observable<[Pin]> {
        let fetchRequest = NSFetchRequest<Pin>(entityName: "Pin")
        return ObservableFetchRequest(fetchRequest: fetchRequest)
    }
    
    func addPin(at location: CLLocationCoordinate2D) {
        let pin = Pin(context: context)
        pin.latitude = location.latitude
        pin.longitude = location.longitude
        
        let _ = try? context.save()
    }
    
    func fetchPhotos(forPin pin: Pin) -> Observable<[Photo]> {
        let fetchRequest = NSFetchRequest<Photo>(entityName: "Photo")
        fetchRequest.predicate = NSPredicate(format: "pin == %@", pin)
        
        return ObservableFetchRequest(fetchRequest: fetchRequest)
    }
    
    func savePhotos(_ photoDatas: [Data], forPin pin: Pin) {
        print("Saving \(photoDatas.count) images into database")
        
        context.perform {
            // Clear existing photos
            let fetchRequest = NSFetchRequest<Photo>(entityName: Photo.entity().name!)
            fetchRequest.propertiesToFetch = []
            fetchRequest.predicate = NSPredicate(format: "pin == %@", pin)
            
            if let photos = try? fetchRequest.execute() {
                for photo in photos {
                    self.context.delete(photo)
                }
            }
            
            // Create descriptions for new photos
            autoreleasepool {
                for data in photoDatas {
                    let photo = NSEntityDescription.insertNewObject(forEntityName: "Photo", into: self.context) as! Photo
                    photo.pin = pin
                    photo.data = data
                }
            }
            
            // Save the context
            do {
                try self.context.save()
            } catch {
                print(error)
            }
        }
    }
    
    func deletePhoto(_ photo: Photo) {
        context.perform {
            self.context.delete(photo)
            let _ = try? self.context.save()
        }
    }
}
