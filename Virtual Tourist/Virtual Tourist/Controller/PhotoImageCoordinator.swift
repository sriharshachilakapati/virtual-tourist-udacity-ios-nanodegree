//
//  PhotoImageCoordinator.swift
//  Virtual Tourist
//
//  Created by Sri Harsha Chilakapati on 21/04/21.
//

import UIKit

class PhotoImageCoordinator {
    enum Change {
        case insert(at: Int)
        case remove(at: Int)
        case change(at: Int)
    }
    
    var images = [UIImage]()
    var changes = [Change]()
    
    var photos: [Photo] = [] {
        didSet {
            syncImages(oldValue)
        }
    }
    
    func applyChanges(to collectionView: UICollectionView) {
        collectionView.performBatchUpdates({
            for change in changes {
                switch change {
                    case .insert(at: let index):
                        collectionView.insertItems(at: [IndexPath(item: index, section: 0)])
                        
                    case .remove(at: let index):
                        collectionView.deleteItems(at: [IndexPath(item: index, section: 0)])
                        
                    case .change(at: let index):
                        collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
                }
            }
        },
        completion: nil)
    }
    
    private func syncImages(_ oldPhotos: [Photo]) {
        changes.removeAll()
        
        var deleted = [Int: UIImage]()
        var nextValidIndex = 0
        
        // Do the diff
        for i in 0 ..< max(photos.count, oldPhotos.count) {
            let new = i < photos.count    ? photos[i]    : nil
            let old = i < oldPhotos.count ? oldPhotos[i] : nil
            
            // If either of them is nil, it means we have reached end of array
            if !compare(index: i, new: new, old: old, deleted: &deleted) {
                break
            }
            
            nextValidIndex += 1
            changes.append(.change(at: i))
        }
        
        // Remove deleted references
        if nextValidIndex >= photos.count {
            images.replaceSubrange(nextValidIndex ..< images.count, with: [])
            
            for i in nextValidIndex ..< images.count {
                changes.append(.remove(at: i))
            }
            
            return
        }
        
        // Insert new images
        for i in nextValidIndex ..< photos.count {
            let photo = photos[i]
            let image = deleted[photo.id.hashValue] ?? UIImage(data: photo.data!)!
            images.append(image)
            changes.append(.insert(at: i))
        }
    }
    
    private func compare(index: Int, new: Photo?, old: Photo?, deleted: inout [Int: UIImage]) -> Bool {
        guard let new = new, let old = old else { return false }
        
        // If both are same, continue
        if (new.id.hashValue == old.id.hashValue) {
            return true
        }
        
        // Delete existing image in old
        let deletedImage = images.remove(at: index)
        deleted[old.id.hashValue] = deletedImage
        
        // Insert new Image
        let image = deleted[new.id.hashValue] ?? UIImage(data: new.data!)!
        images.insert(image, at: index)
        
        return true
    }
}
