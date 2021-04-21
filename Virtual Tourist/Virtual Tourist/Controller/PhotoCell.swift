//
//  PhotoCell.swift
//  Virtual Tourist
//
//  Created by Sri Harsha Chilakapati on 18/04/21.
//

import UIKit

class PhotoCell: UICollectionViewCell {
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    func setImage(image: UIImage?) {
        photoImageView.image = image
        
        if let _ = image {
            activityIndicatorView.isHidden = true
        } else {
            activityIndicatorView.isHidden = false
        }
    }
}
