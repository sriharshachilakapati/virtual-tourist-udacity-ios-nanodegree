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
    
    var selectedPin: Pin!
    
    private var images = [UIImage]()
    private var fetchImageObservable: Observable<[Photo]>!
    
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
    
    private func handlePhotosChanged(photos: [Photo]) {
        DispatchQueue.main.async {
            self.images = [UIImage]()
            
            print("Got \(photos.count) after update")
            
            for photo in photos {
                if let image = UIImage(data: photo.data!) {
                    self.images.append(image)
                }
            }
            
            self.noImagesLabel.isHidden = photos.count != 0
            self.collectionView.reloadData()
        }
    }
    
    @IBAction func onNewCollectionButtonClicked() {
        fetchImages(forceDownload: true)
    }
    
    private func fetchImages(forceDownload: Bool) {
        fetchImageObservable = repository.fetchPhotos(forPin: selectedPin, forceFetch: forceDownload)
        fetchImageObservable.listenForChanges(handlePhotosChanged(photos:))
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
}
