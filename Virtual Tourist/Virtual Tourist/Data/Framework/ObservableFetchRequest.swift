//
//  ObservableFetchRequest.swift
//  Virtual Tourist
//
//  Created by Sri Harsha Chilakapati on 18/04/21.
//

import Foundation
import CoreData
import UIKit

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
        let context = (UIApplication.shared.delegate as! AppDelegate).backgroundContext
        
        context.performAndWait {
            if let results = try? self.fetchRequest.execute() {
                self.dispatchChange(changed: results)
            }
        }
    }
}
