//
//  MapVC.swift
//  Parkit
//
//  Created by Jason Campoverde on 3/31/17.
//  Copyright © 2017 Jason Campoverde. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapVC: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UITextFieldDelegate {
    /*
     IBOutlets
     */
    @IBOutlet weak var theMap: MKMapView!
    @IBOutlet weak var setRemovePinBtn: CustomButton!
    @IBOutlet weak var centerOnPinBtn: CustomButton!
    @IBOutlet weak var noteTextField: UITextField!
    
    
    
    
    /*
     Variable declarations
     */
    var userHeading = MKUserTrackingMode(rawValue: 2)
    var annotation = MKPointAnnotation()
    var locationManager = CLLocationManager()
    let regionRadius: CLLocationDistance = 1000
    var defaults = UserDefaults.standard
    var wasPinSet: Bool?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Checks whether the user has allowed location service authorization
        locationAuthStatus()
        
        
        //Checks the defaults to see if a pin was set.
        if defaults.bool(forKey: Constants.Defaults.wasPinSet) == true {
            print("There was a pin set on app start")
            print("Latitude: \(String(describing: defaults.value(forKey: Constants.Defaults.latitude))) Longitude: \(String(describing: defaults.value(forKey: Constants.Defaults.longitude))))")
            
            annotation.coordinate.latitude = defaults.value(forKey: Constants.Defaults.latitude) as! CLLocationDegrees
            annotation.coordinate.longitude = defaults.value(forKey: Constants.Defaults.longitude) as! CLLocationDegrees
            print(annotation)
            
            self.theMap.addAnnotation(annotation)
            self.annotation.title = (defaults.value(forKey: Constants.Defaults.savedNote) as! String)
            
            setRemovePinBtn.setTitle("Remove Pin", for: .normal)
            
        } else{
            print("else")
            self.centerOnPinBtn.isHidden = true
        }
        
        
        /*
         Properties for the map
         */
        theMap.delegate = self
        theMap.showsCompass = false
        theMap.showsUserLocation = true
        theMap.showsPointsOfInterest = true
        theMap.showsBuildings = true
        
        
        //Location manager properties
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startMonitoringSignificantLocationChanges()
        
        
        //Dismisses the keyboard
        noteTextField.delegate = self
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    
    /*
     IBActions
     */
    @IBAction func setPinBtn(_ sender: Any) {
        print("\nSET PIN PRESSED")
        let unwrappedBool = defaults.value(forKey: Constants.Defaults.wasPinSet) ?? false
        if unwrappedBool as! Bool == true{
            let alert = UIAlertController(title: "Warning", message: "Remove pin?", preferredStyle: .alert)
            alert.addAction((UIAlertAction(title: "Cancel", style: .cancel, handler: nil)))
            alert.addAction(UIAlertAction(title: "Remove", style: .destructive, handler: { action in
                self.removePin()
            }))
            self.present(alert, animated: true, completion: nil)
        } else{
            setPin()
            saveNote(note: self.noteTextField.text)
            self.annotation.title = (defaults.value(forKey: Constants.Defaults.savedNote) as! String)
            
        }
        
    }
    
    
    @IBAction func centerOnPinBtn(_ sender: Any) {
        print("\nCENTER ON PIN PRESSED")
        if defaults.bool(forKey: Constants.Defaults.wasPinSet){
            centerMapOnLocation(location: CLLocation(latitude: defaults.value(forKey: Constants.Defaults.latitude) as! CLLocationDegrees, longitude: defaults.value(forKey: Constants.Defaults.longitude) as! CLLocationDegrees))
        }
    }
    
    
    @IBAction func centerOnCurrentLocationBtn(_ sender: Any) {
        print("\nCENTER ON CURRENT LOCATION PRESSED")
        locationAuthStatus()
        centerMapOnLocation(location: GpsLocation.sharedInstance.coordinates!)
    }
    
    
    
    
    
    /*
     Functions
     */
    
    //Asks user for permission to use location
    func locationAuthStatus() {
        if CLLocationManager.authorizationStatus() == .authorizedAlways {
            GpsLocation.sharedInstance.latitude = locationManager.location?.coordinate.latitude
            GpsLocation.sharedInstance.longitude = locationManager.location?.coordinate.longitude
            GpsLocation.sharedInstance.coordinates = locationManager.location
            print("\nLocation service authorized. \(String(describing: GpsLocation.sharedInstance.coordinates))")
            centerMapOnLocation(location: GpsLocation.sharedInstance.coordinates!)
        } else {
            locationManager.requestAlwaysAuthorization()
            print("\nLocation authorization denied or not determined.\n")
            let alert = UIAlertController(title: "Location services disabled.", message: "Please go to settings and enable location services for this app to function correctly.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    //Sets pin based on current GPS location.
    func setPin(){
        print("setPin() called.")
        locationAuthStatus()
        self.setRemovePinBtn.setTitle("Remove Pin", for: .normal)
        self.centerOnPinBtn.isHidden = false
        wasPinSet = true
        
        defaults.set(wasPinSet, forKey: Constants.Defaults.wasPinSet)
        defaults.set(GpsLocation.sharedInstance.latitude, forKey: Constants.Defaults.latitude)
        defaults.set(GpsLocation.sharedInstance.longitude, forKey: Constants.Defaults.longitude)
        
        self.annotation.coordinate = CLLocationCoordinate2D(latitude: GpsLocation.sharedInstance.latitude!, longitude: GpsLocation.sharedInstance.longitude!)
        self.theMap.addAnnotation(annotation)
        
        print("THIS IS \(annotation.coordinate)")
        
        self.noteTextField.isHidden = true
    }
    
    //Removes pin if there is one set.
    func removePin(){
        print("removePin() called.")
        self.setRemovePinBtn.setTitle("Set Pin", for: .normal)
        wasPinSet = false
        defaults.set(wasPinSet, forKey: Constants.Defaults.wasPinSet)
        self.theMap.removeAnnotation(annotation)
        self.centerOnPinBtn.isHidden = true
        self.noteTextField.text = ""
        self.noteTextField.isHidden = false
        
       
    }
    
    
    //Saves note onto user defaults.
    func saveNote(note: String?){
        if let note = note{
            defaults.set(note, forKey: Constants.Defaults.savedNote)
            print(defaults.value(forKey: Constants.Defaults.savedNote)!)
            print("Note saved")
        } else{
            defaults.set("", forKey: Constants.Defaults.savedNote)
            print("Could not save note")
        }
        
    }
    
    
    //Centers the map on the location provided.
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                                                                  regionRadius * 0.5, regionRadius * 0.5)
        theMap.setRegion(coordinateRegion, animated: true)
    }
    
    
    //Dismisses keyboard when user presses return key.
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.noteTextField.resignFirstResponder()
        return true
    }
    
    //Dismisses keyboard when user touches anywhere outside of the keyboard.
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0{
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0{
                self.view.frame.origin.y += keyboardSize.height
            }
        }
    }
}

