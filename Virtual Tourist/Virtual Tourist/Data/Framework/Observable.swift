//
//  Observable.swift
//  Virtual Tourist
//
//  Created by Sri Harsha Chilakapati on 15/04/21.
//

import Foundation

/// This class is a poor man's (that's me) `Observable` from RxSwift. However, one major difference is that we don't
/// care about an extra bag to store disposables. Instead, the listeners work as long as the reference is kept for the
/// `Observable` instance that you're listening to.
///
/// This class is similar to an observable there, but is also different at the same time. Observables of RxSwift will
/// be treated as a continous streams of data, where the same element that is presently in the stream can be queried.
/// I didn't have a use case for that, and hence I have modeled it just for notification of changes. You can think of
/// this as a Swift port of Android's `LiveData` class, but one that is not tied to any view's lifecycle.
class Observable<T> {
    typealias ChangeListener = (T) -> Void
    
    private var listeners = [ChangeListener]()
    private var oneTimeListeners = [ChangeListener]()
    private var pendingUpdate: T?
    
    
    /// Register a listener that will listen to changes to the item it carries.
    /// - Parameter listener: A `ChangeListener` that is invoked when any change happens to the item.
    func listenForChanges(_ listener: @escaping ChangeListener) {
        if let pendingUpdate = pendingUpdate {
            listener(pendingUpdate)
            self.pendingUpdate = nil
        }
        
        listeners.append(listener)
    }
    
    /// Register a listener that will listen to changes to the item it carries. However, the listener will be fired only
    /// once, after which it is removed and no longer exists.
    /// - Parameter listener: A `ChangeListener` that is invoked when any change happens to the item.
    func listenOnce(_ listener: @escaping ChangeListener) {
        if let pendingUpdate = pendingUpdate {
            listener(pendingUpdate)
            return
        }
        
        oneTimeListeners.append(listener)
    }
    
    /// Notify all the listeners about a specific change.
    /// - Parameter changed: The item that is changed.
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
