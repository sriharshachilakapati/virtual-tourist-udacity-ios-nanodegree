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
    private var oneTimeListeners = [ChangeListener]()
    private var pendingUpdate: T?
    
    func listenForChanges(_ listener: @escaping ChangeListener) {
        if let pendingUpdate = pendingUpdate {
            listener(pendingUpdate)
            self.pendingUpdate = nil
        }
        
        listeners.append(listener)
    }
    
    func listenOnce(_ listener: @escaping ChangeListener) {
        if let pendingUpdate = pendingUpdate {
            listener(pendingUpdate)
            return
        }
        
        oneTimeListeners.append(listener)
    }
    
    func dispatchChange(changed: T) {
        oneTimeListeners.forEach { listener in listener(changed) }
        oneTimeListeners.removeAll()
        
        if listeners.isEmpty {
            pendingUpdate = changed
            return
        }
        
        listeners.forEach { listener in listener(changed) }
    }
}
