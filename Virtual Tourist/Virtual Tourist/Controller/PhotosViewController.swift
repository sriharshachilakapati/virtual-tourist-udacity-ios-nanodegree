//
//  PhotosViewController.swift
//  Virtual Tourist
//
//  Created by Sri Harsha Chilakapati on 13/04/21.
//

import UIKit
import MapKit

class PhotosViewController: UIViewController {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var selectedPin: Pin!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: selectedPin.latitude, longitude: selectedPin.longitude)
        annotation.title = "Selected Location"
        
        mapView.addAnnotation(annotation)
        
        let camera = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 15000, longitudinalMeters: 15000)
        mapView.setRegion(camera, animated: true)
    }
}
