//
//  ViewController.swift
//  Virtual Tourist
//
//  Created by Sri Harsha Chilakapati on 11/04/21.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    private let repository = VirtualTouristRepository()
    
    @IBOutlet weak var mapView: MKMapView!
    
    private var longPressRecognizer: UILongPressGestureRecognizer!
    private var fetchPinsObservable: Observable<[Pin]>!
    private var selectedPin: Pin!
    
    private var pins: [Pin]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        longPressRecognizer = UILongPressGestureRecognizer(
            target: self,
            action: #selector(onMapLongPress))
        
        mapView.addGestureRecognizer(longPressRecognizer)
        
        fetchPinsObservable = repository.fetchPins()
        
        fetchPinsObservable.listenForChanges { pins in
            DispatchQueue.main.async {
                self.pins = pins
                self.updatePins(pins)
            }
        }
        
        mapView.delegate = self
    }
    
    private func updatePins(_ pins: [Pin]) {
        mapView.removeAnnotations(mapView.annotations)
        
        for pin in pins {
            var coordinate = CLLocationCoordinate2D()
            coordinate.latitude = pin.latitude
            coordinate.longitude = pin.longitude
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            mapView.addAnnotation(annotation)
        }
    }

    @objc private func onMapLongPress() {
        if longPressRecognizer.state != .began {
            return
        }
        
        let point = longPressRecognizer.location(in: mapView)
        let coordinate = mapView.convert(point, toCoordinateFrom: mapView)
        
        repository.addPin(at: coordinate)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toPhotosScreen" {
            let destVC = segue.destination as! PhotosViewController
            destVC.selectedPin = selectedPin
        }
    }
}

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let pinView = mapView.dequeueReusableAnnotationView(withIdentifier: "pin") as? MKPinAnnotationView ?? {
            let view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin")
            
            view.canShowCallout = true
            view.pinTintColor = .red
            return view
        }()
        
        pinView.annotation = annotation
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let coordinate = view.annotation!.coordinate
        self.selectedPin = pins.filter { $0.latitude == coordinate.latitude && $0.longitude == coordinate.longitude }.first!
        
        performSegue(withIdentifier: "toPhotosScreen", sender: self)
    }
}
