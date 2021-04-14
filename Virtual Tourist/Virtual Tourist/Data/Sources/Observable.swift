//
//  Observable.swift
//  Virtual Tourist
//
//  Created by Sri Harsha Chilakapati on 15/04/21.
//

import Foundation

class Observable<T> {
    typealias ChangeListener = (T) -> Void
    
    private var listeners = [ChangeListener]()
    private var pendingUpdate: T?
    
    func listenForChanges(_ listener: @escaping ChangeListener) {
        if let pendingUpdate = pendingUpdate {
            listener(pendingUpdate)
            self.pendingUpdate = nil
        }
        
        listeners.append(listener)
    }
    
    func dispatchChange(changed: T) {
        if listeners.isEmpty {
            pendingUpdate = changed
            return
        }
        
        listeners.forEach { listener in listener(changed) }
    }
}
