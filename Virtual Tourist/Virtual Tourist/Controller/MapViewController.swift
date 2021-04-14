//
//  ViewController.swift
//  Virtual Tourist
//
//  Created by Sri Harsha Chilakapati on 11/04/21.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    @IBOutlet weak var mapView: MKMapView!
    
    private var longPressRecognizer: UILongPressGestureRecognizer!
    private var coordinates: CLLocationCoordinate2D?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        longPressRecognizer = UILongPressGestureRecognizer(
            target: self,
            action: #selector(onMapLongPress))
        
        mapView.addGestureRecognizer(longPressRecognizer)
    }

    @objc private func onMapLongPress() {
        if longPressRecognizer.state != .began {
            return
        }
        
        let point = longPressRecognizer.location(in: mapView)
        coordinates = mapView.convert(point, toCoordinateFrom: mapView)
        
        performSegue(withIdentifier: "toPhotosScreen", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toPhotosScreen" {
            let destVC = segue.destination as! PhotosViewController
            destVC.location = coordinates!
        }
    }
}

