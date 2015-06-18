//
//  FirstViewController.swift
//  MyLocations
//
//  Created by Daniel Kwiatkowski on 2015-06-09.
//  Copyright (c) 2015 Daniel Kwiatkowski. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData

class CurrentLocationViewController: UIViewController, CLLocationManagerDelegate {

    let locationManager = CLLocationManager()
    var location:CLLocation?

    var updatingLocation = false
    var lastLocationError:NSError?
    
    let geocoder = CLGeocoder()//object used to will perform geocoding to help turn coordinates into a human-readable address
    var placemark: CLPlacemark?//optional to to look up address
    
    var performingReverseGeocoding = false
    var lastGeocodingError: NSError?
    
    var timer:NSTimer?
    
    var managedObjectContext: NSManagedObjectContext!
    
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
        
        if updatingLocation {
            stopLocationManager()
        } else {
            location = nil
            lastLocationError = nil
            placemark = nil
            lastGeocodingError = nil
            startLocationManager()
        }
        
        updateLabels()
        configureGetButton()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateLabels()
        configureGetButton()
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
        configureGetButton()
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!){
        let newLocation = locations.last as! CLLocation
        println("didUpdateLocations \(newLocation)")
        // cached-result, the location manager  may initallly give you the most recently found locaiton under the assumption that you might not have moved much sine last time
        if newLocation.timestamp.timeIntervalSinceNow < -5 {
            return
        }
        
        
        if newLocation.horizontalAccuracy < 0 {
            return
        }
        //this calculates the distance the new reading and previous reading, if there was one
        //we are doing this so that any calculations still work even if you weren't able to calculate the true distance yet
        var distance = CLLocationDistance(DBL_MAX)
        if let location = location{
            distance = newLocation.distanceFromLocation(location)
        }
        
        // this gives a more farily accurate reading
        if location == nil || location!.horizontalAccuracy > newLocation.horizontalAccuracy{
            
            lastLocationError = nil
            location = newLocation
            updateLabels()
        
            if newLocation.horizontalAccuracy <= locationManager.desiredAccuracy {
                println("*** We're done!")
                stopLocationManager()
                configureGetButton()
                // this forces a reverse geocoding for the final location, even if the app is already currently performing another geocoding request
                if distance < 0 {
                    performingReverseGeocoding = false
                }
            }
            if !performingReverseGeocoding{
                println("Going to Geocode")
                
                performingReverseGeocoding = true
                //closure that handles the placemark
                geocoder.reverseGeocodeLocation(location, completionHandler: {
                    placemarks, error in
                    println("*** Found placemarkers: \(placemarks), error: \(error)")
                    self.lastGeocodingError = error
                    if error == nil && !placemarks.isEmpty{
                        self.placemark = placemarks.last as? CLPlacemark
                    } else {
                        self.placemark = nil
                    }
                    self.performingReverseGeocoding = false
                    self.updateLabels()
                })
            }
        //this is to stop scanning for the location
        }else if distance < 1.0 {
            let timeInterval = newLocation.timestamp.timeIntervalSinceDate(location!.timestamp)
            
            if timeInterval > 10 {
                println("*** Force done !")
                stopLocationManager()
                updateLabels()
                configureGetButton()
            }
        }
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
            
            if let placemark = placemark{
                addressLabel.text = stringFromPlacemark(placemark)
                println("Success!")
            } else if performingReverseGeocoding{
                addressLabel.text = "Searching for Address"
            } else if lastGeocodingError != nil{
                addressLabel.text = "Error Finding Address"
            } else {
                addressLabel.text = "No address Found"
            }
        } else {
            latitudeLabel.text = ""
            longitudeLabel.text = ""
            addressLabel.text = ""
            tagButton.hidden = false

            //error-handling helps narrow down the the nearest location by 10 meters for battery performance and cpu usage
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
            //stop looking for the after a minute
            timer = NSTimer.scheduledTimerWithTimeInterval(60, target: self, selector: Selector("didTimeOut"), userInfo: nil, repeats: false)
        }
    }
    
    func stopLocationManager(){
        if updatingLocation{
            if let timer = timer{
                timer.invalidate()
            }
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            updatingLocation = false
        //the if-statement in here that checks whether the boolean instance variable updatingLocation is true or false, if it is false, then the location manager wasnt currently active and there is no need to stop it
        }
    }
    
    func configureGetButton(){
        if updatingLocation{
            getButton.setTitle("Stop", forState: .Normal)
        } else {
            getButton.setTitle("Get My Location", forState: .Normal)
        }
    }
    
    func stringFromPlacemark(placemark:CLPlacemark) -> String{
        return "\(placemark.subLocality) \(placemark.thoroughfare)," + "\(placemark.locality)"
    }
    
    func didTimeOut(){
        println("*** Time Out")
        
        if location == nil{
            stopLocationManager()
            
            lastLocationError = NSError(domain: "MyLocationErrorDomain", code: 1, userInfo: nil)
            updateLabels()
            configureGetButton()
        }
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "TagLocation" {
            let navigationController = segue.destinationViewController as! UINavigationController
            let controller = navigationController.topViewController as! LocationDetailsTableViewController
            
            controller.coordinate = location!.coordinate
            controller.placemark = placemark
            controller.managedObjectContext = managedObjectContext
            
        }
    }


}

