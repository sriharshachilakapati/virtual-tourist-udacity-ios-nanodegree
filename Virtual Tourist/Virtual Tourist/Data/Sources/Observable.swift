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
    
    func listenForChanges(_ listener: @escaping ChangeListener) {
        listeners.append(listener)
    }
    
    func dispatchChange(changed: T) {
        listeners.forEach { listener in listener(changed) }
    }
}
