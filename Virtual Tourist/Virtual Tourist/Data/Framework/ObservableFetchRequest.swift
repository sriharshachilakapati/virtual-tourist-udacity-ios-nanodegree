//
//  ObservableFetchRequest.swift
//  Virtual Tourist
//
//  Created by Sri Harsha Chilakapati on 18/04/21.
//

import Foundation
import CoreData
import UIKit

/// This class is an `Observable` that observes the results of an `NSFetchRequest`. This works by listening to the
/// events of CoreData framework from the Notification Center and reacting to them. Having said that, this will not
/// cause any memory leak since we remove observers when this object no longer exists.
class ObservableFetchRequest<T: NSFetchRequestResult>: Observable<[T]> {
    private let fetchRequest: NSFetchRequest<T>
    
    init(fetchRequest: NSFetchRequest<T>) {
        self.fetchRequest = fetchRequest
        super.init()
        
        NotificationCenter.default.addObserver(self, selector: #selector(execute), name: .NSManagedObjectContextObjectsDidChange, object: nil)
        execute()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func execute() {
        DispatchQueue.main.async {
            let context = (UIApplication.shared.delegate as! AppDelegate).backgroundContext
            
            context.perform {
                if let results = try? self.fetchRequest.execute() {
                    self.dispatchChange(changed: results)
                }
            }
        }
    }
}
