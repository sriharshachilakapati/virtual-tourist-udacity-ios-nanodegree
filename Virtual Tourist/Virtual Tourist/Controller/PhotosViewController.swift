//
//  PhotosViewController.swift
//  Virtual Tourist
//
//  Created by Sri Harsha Chilakapati on 13/04/21.
//

import UIKit
import MapKit

class PhotosViewController: UIViewController {
    private let repository = VirtualTouristRepository()
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var noImagesLabel: UILabel!
    @IBOutlet weak var activityIndicatorView: UIView!
    @IBOutlet weak var newCollectionButton: UIBarButtonItem!
    
    var selectedPin: Pin!
    
    private var images = [UIImage]()
    private var photos = [Photo]()
    private var fetchImageObservable: Observable<PhotoFetchProgress>!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: selectedPin.latitude, longitude: selectedPin.longitude)
        annotation.title = "Selected Location"
        
        mapView.addAnnotation(annotation)
        
        let camera = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 15000, longitudinalMeters: 15000)
        mapView.setRegion(camera, animated: true)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.collectionViewLayout = UICollectionViewFlowLayout()
        
        fetchImages(forceDownload: false)
    }
    
    private func handlePhotosChanged(photos: [Photo], didFetchFinish: Bool) {
        DispatchQueue.main.async {
            self.images.removeAll()
            self.photos.removeAll()
            
            print("Got \(photos.count) after update. Finished is \(didFetchFinish)")
            
            for photo in photos {
                if let data = photo.data, let image = UIImage(data: data) {
                    self.images.append(image)
                    self.photos.append(photo)
                }
            }
            
            if didFetchFinish {
                self.activityIndicatorView.isHidden = true
                self.newCollectionButton.isEnabled = true
            }
            
            self.noImagesLabel.isHidden = photos.count != 0
            self.collectionView.reloadData()
        }
    }
    
    @IBAction func onNewCollectionButtonClicked() {
        fetchImages(forceDownload: true)
    }
    
    private func fetchImages(forceDownload: Bool) {
        activityIndicatorView.isHidden = false
        newCollectionButton.isEnabled = false
        fetchImageObservable = repository.fetchPhotos(for: selectedPin, forceFetch: forceDownload)
        fetchImageObservable.listenForChanges(handlePhotosChanged(photos:didFetchFinish:))
    }
}

extension PhotosViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! PhotoCell
        cell.photoImageView.image = images[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("Reloading collectionView: Count is \(images.count)")
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = 128
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        repository.deletePhoto(photos[indexPath.row])
    }
}
