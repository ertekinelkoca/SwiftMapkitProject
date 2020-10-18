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
//to save info
import CoreData

class ViewController: UIViewController , MKMapViewDelegate , CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    //this gives users location
    var locationManager = CLLocationManager()
    
    var choosenLatitude = Double()
    var chosenLongitude = Double()
    
    var selectedTitle = ""
    var selectedID : UUID?
    
    var annotationTitle = ""
    var annotationSubtitle = ""
    var annotationLatitude = Double()
    var annotationLongitude = Double()
    
    @IBOutlet weak var mainText: UITextField!
    @IBOutlet weak var commentText: UITextField!
    
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
        
        if selectedTitle != ""{
            //CoreData
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Places")
            let idString = selectedID!.uuidString
            
            fetchRequest.predicate = NSPredicate(format: "id = %@",idString)
            fetchRequest.returnsObjectsAsFaults = false
            
            do{
                let results = try context.fetch(fetchRequest)
                
                if results.count > 0 {
                    for result in results as! [NSManagedObject] {
                        if let title = result.value(forKey: "title") as? String {
                            annotationTitle = title
                            if let subtitle = result.value(forKey: "subtitle") as? String {
                                annotationSubtitle = subtitle
                                if let longitude = result.value(forKey: "longitude") as? Double {
                                    annotationLongitude = longitude
                                    if let latitude = result.value(forKey: "latitude") as? Double {
                                         annotationLatitude = latitude
                                        
                                        let annotation = MKPointAnnotation()
                                        annotation.title = annotationTitle
                                        annotation.subtitle = annotationSubtitle
                                        let coordinate = CLLocationCoordinate2D(latitude: annotationLatitude, longitude: annotationLongitude)
                                        annotation.coordinate = coordinate
                                        
                                        mapView.addAnnotation(annotation)
                                        mainText.text = annotationTitle
                                        commentText.text = annotationSubtitle
                                        
                                        locationManager.stopUpdatingLocation()
                                        
                                        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                                        let region = MKCoordinateRegion(center: coordinate, span: span)
                                        mapView.setRegion(region, animated: true)
                                    }
                                }
                            }
                        }
                    }
                }
            }catch{
                    
            }
            
        } else {
            //AddData
            
        }
        
    }
    
    @objc func chooseLocation(gestureRecognizer:UILongPressGestureRecognizer){
        // pin adding
        
        // To define whether is touched on screen or not
        if gestureRecognizer.state == .began {
            
            let touchedPoint = gestureRecognizer.location(in: self.mapView)
            let touchedCoordinates = self.mapView.convert(touchedPoint, toCoordinateFrom: self.mapView)
            choosenLatitude = touchedCoordinates.latitude
            chosenLongitude = touchedCoordinates.longitude
            
            let annotation = MKPointAnnotation()
            annotation.title = mainText.text
            annotation.coordinate = touchedCoordinates
            annotation.subtitle = commentText.text
            self.mapView.addAnnotation(annotation)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if selectedTitle == "" {
            //includes longitude and latitude
            let location = CLLocationCoordinate2D.init(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
            // zoom setting.the lower the delta number , the higher the zoom
            let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            // to center the location and the setting of how close to zoom
            let region = MKCoordinateRegion(center: location, span: span)
            mapView.setRegion(region, animated: true)
        }
    }
    
    //this is created for the fixed users selected point not current point
    //to specialize pin in mapview , if you dont use this then swift uses its default annotation
    //when clicked info , redirect to the navigation
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        //do not want to show users location as pin
        //the goal to do this is we would like to show pinned point not users point
        if annotation is MKUserLocation {
            return nil
        }
        
        //Purpuse of the creation of this variable is pinview will need more than one time
        let reusedId = "myAnnotation"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reusedId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reusedId)
            //to show extra information in baloon
            pinView?.canShowCallout = true
            //to change color of annotation
            pinView?.tintColor = UIColor.black
            //to enable info button
            let button = UIButton(type: UIButton.ButtonType.detailDisclosure)
            //show on right
            pinView?.rightCalloutAccessoryView = button
        }
        else{
            pinView?.annotation = annotation
        }
        return pinView
    }
    
    //to findout whether info button is clicked or not
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if selectedTitle != "" {
            
            let requestLocation = CLLocation(latitude: annotationLatitude, longitude: annotationLongitude)
            
            //it enables us to make connection in between places and coordinates
            CLGeocoder().reverseGeocodeLocation(requestLocation) { (placemarks, error) in
                //closure , means after to do some calcutaions it returns something, in other words callback,Like Aspect
                //the purpose of fetching placemarks is to start navigation via this object
                
                if let placemark = placemarks {
                    if placemark.count > 0 {
                        //to start navigation mkplacemark object should be obtained
                        let newPlacemark = MKPlacemark(placemark: placemark[0])
                        //to start navgitation
                        let item = MKMapItem(placemark: newPlacemark)
                        //in clousure you should use self.
                        item.name = self.annotationTitle
                        
                        let launchOptions = [MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving]
                        item.openInMaps(launchOptions: launchOptions)
                        
                    }
                }
            }
        }
    }

    @IBAction func saveButtonClicked(_ sender: Any) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        //NSmanaged object
        let context = appDelegate.persistentContainer.viewContext
        
        let newPlace = NSEntityDescription.insertNewObject(forEntityName: "Places", into: context)
        newPlace.setValue(mainText.text, forKey: "title")
        newPlace.setValue(commentText.text, forKey: "subtitle")
        newPlace.setValue(choosenLatitude, forKey: "latitude")
        newPlace.setValue(chosenLongitude, forKey: "longitude")
        newPlace.setValue(UUID(), forKey: "id")
        
        do { try context.save()
            print("view controller save success")
        }
        catch{
            print("view controller save exception")
        }
        
        NotificationCenter.default.post(name: NSNotification.Name("newPlace"), object: nil)
        navigationController?.popViewController(animated: true)
    }
} 

