//
//  FirstViewController.swift
//  MyLocations
//
//  Created by Daniel Kwiatkowski on 2015-06-09.
//  Copyright (c) 2015 Daniel Kwiatkowski. All rights reserved.
//

import UIKit
import CoreLocation

class CurrentLocationViewController: UIViewController, CLLocationManagerDelegate {

    let locationManager = CLLocationManager()
    var location:CLLocation?

    var updatingLocation = false
    var lastLocationError:NSError?
    
    @IBOutlet weak var messageLabel:UILabel!
    @IBOutlet weak var latitudeLabel:UILabel!
    @IBOutlet weak var longitudeLabel:UILabel!
    @IBOutlet weak var addressLabel:UILabel!
    @IBOutlet weak var tagButton:UIButton!
    @IBOutlet weak var getButton:UIButton!
    
    @IBAction func getLocation(){
        let authStatus = CLLocationManager.authorizationStatus()

        //This checks the current authorization status. If it is .NotDetermined, meaning that this app has not asked for permission yet, then the app will request “When In Use” authorization. That allows the app to get location updates while it is open and the user is interacting with it.
        if authStatus == .NotDetermined {
            locationManager.requestWhenInUseAuthorization()
            return
        }
        if authStatus == .Denied || authStatus == .Restricted{
            showLocationServicesDeniedAlert()
            return
        }
        
        startLocationManager()
        updateLabels()
        
        
        //you wil receive your location withing 10 meters
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.startUpdatingLocation()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateLabels()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


     func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!){
        println("didFailWithError \(error)")
        //this means that the location manager is unable to obtain the location manager and was unable to obtain a location right now, its letting you know that for now it could not get any location information
        if error.code == CLError.LocationUnknown.rawValue{
            return
        }
        
        // stores the error object into a new instance object
        lastLocationError = error
        
        stopLocationManager()
        updateLabels()
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!){
        let newLocation = locations.last as! CLLocation
        println("didUpdateLocations \(newLocation)")
        
        lastLocationError = nil
        location = newLocation
        updateLabels()
    }
    
    func showLocationServicesDeniedAlert(){
        let alert = UIAlertController(title: "Location Services Disabled", message: "Please enable location services for this app in Settings", preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        
        alert.addAction(okAction)
        
        presentViewController(alert, animated: true, completion: nil)
        
    }
    
    func updateLabels(){
        if let location =  location{
            latitudeLabel.text = String(format: "%.8f", location.coordinate.latitude)
            longitudeLabel.text = String(format: "%.8f", location.coordinate.longitude)
            tagButton.hidden = false
            messageLabel.text = ""
        } else {
            latitudeLabel.text = ""
            longitudeLabel.text = ""
            addressLabel.text = ""
            tagButton.hidden = false
            
            //checking if the user accepts that the app gives permission to use the location services
            var statusMessage:String
            if let error = lastLocationError{
                //it checks if the first error(in the domain name kCLErrorDomain) is denied by the user
                if error.domain == kCLErrorDomain && error.code == CLError.Denied.rawValue{
                    statusMessage = "Location Services Disabled"
                }else{
                    //if the error is something else you simply say "Getting Fixed Location"
                    statusMessage = "Error Getting Location"
                }
                //if there is no error it might be still impossible if the user disabled Location Services completely on their app
            } else if !CLLocationManager.locationServicesEnabled(){
                statusMessage = "Location Services Disabled"
                // continues if there are no errors
            } else if updatingLocation {
                statusMessage = "Searching..."
            } else {
                statusMessage = "Tap 'Get My Location'to Start"
            }
            messageLabel.text = statusMessage
        }
    }
    
    func startLocationManager(){
        if CLLocationManager.locationServicesEnabled(){
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            updatingLocation = true
        }
    }
    
    func stopLocationManager(){
        if updatingLocation{
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            updatingLocation = false
        //the if-statement in here that checks whether the boolean instance variable updatingLocation is true or false, if it is false, then the location manager wasnt currently active and there is no need to stop it
        }
    }
}

