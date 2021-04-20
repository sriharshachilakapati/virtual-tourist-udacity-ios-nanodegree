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
        let fetchRequest = NSFetchRequest<Pin>(entityName: String(describing: Pin.self))
        return ObservableFetchRequest(fetchRequest: fetchRequest)
    }
    
    func addPin(at location: CLLocationCoordinate2D) {
        let pin = Pin(context: context)
        pin.latitude = location.latitude
        pin.longitude = location.longitude
        
        let _ = try? context.save()
    }
    
    private func getPhotosFetchRequest(for pin: Pin) -> NSFetchRequest<Photo> {
        let fetchRequest = NSFetchRequest<Photo>(entityName: String(describing: Photo.self))
        fetchRequest.predicate = NSPredicate(format: "pin == %@", pin)
        return fetchRequest
    }
    
    func fetchPhotos(forPin pin: Pin) -> Observable<[Photo]> {
        return ObservableFetchRequest(fetchRequest: getPhotosFetchRequest(for: pin))
    }
    
    func getPhotoCount(for pin: Pin) -> Int {
        return (try? context.count(for: getPhotosFetchRequest(for: pin))) ?? 0
    }
    
    func savePhotos(_ photoDatas: [Data], forPin pin: Pin) {
        print("Saving \(photoDatas.count) images into database")
        
        // Special case: We want to be notified even for 0 photos
        if photoDatas.count == 0 {
            NotificationCenter.default.post(.init(name: .NSManagedObjectContextObjectsDidChange))
            return
        }
        
        context.perform {
            // Clear existing photos
            let fetchRequest = self.getPhotosFetchRequest(for: pin)
            fetchRequest.propertiesToFetch = []
            
            if let photos = try? fetchRequest.execute() {
                for photo in photos {
                    self.context.delete(photo)
                }
            }
            
            // Create descriptions for new photos
            autoreleasepool {
                for data in photoDatas {
                    let photo = NSEntityDescription.insertNewObject(forEntityName: String(describing: Photo.self), into: self.context) as! Photo
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
