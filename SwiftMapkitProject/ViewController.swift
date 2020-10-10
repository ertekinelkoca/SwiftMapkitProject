//
//  ViewController.swift
//  SwiftMapkitProject
//
//  Created by mac on 8.10.2020.
//

import UIKit
import MapKit
//to fetch users location
import CoreLocation

class ViewController: UIViewController , MKMapViewDelegate , CLLocationManagerDelegate{

    @IBOutlet weak var mapView: MKMapView!
    //this gives users location
    var locationManager = CLLocationManager()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //to make available these protocols for this controller
        mapView.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        //to get permisson from user
        locationManager.requestWhenInUseAuthorization()
        //only manager not delegate takes place now , because just starts
        locationManager.startUpdatingLocation()
        
        //Users pin selection gesture recognizer
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(chooseLocation(gestureRecognizer:)))
        gestureRecognizer.minimumPressDuration = 3
        mapView.addGestureRecognizer(gestureRecognizer)
        
    }
    
    @objc func chooseLocation(gestureRecognizer:UILongPressGestureRecognizer){
        // pin adding
        
        // To define whether is touched on screen or not
        if gestureRecognizer.state == .began {
            
            let touchedPoint = gestureRecognizer.location(in: self.mapView)
            let touchedCoordinates = self.mapView.convert(touchedPoint, toCoordinateFrom: self.mapView)
            
            let annotation = MKPointAnnotation()
            annotation.title = "New Annotation"
            annotation.coordinate = touchedCoordinates
            annotation.subtitle = "Route Book"
            self.mapView.addAnnotation(annotation)
        }
        
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        //includes longitude and latitude
        let location = CLLocationCoordinate2D.init(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
        // zoom setting.the lower the delta number , the higher the zoom
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        // to center the location and the setting of how close to zoom
        let region = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(region, animated: true)
        
    }


}

