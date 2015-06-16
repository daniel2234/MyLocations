//
//  LocationDetailsTableViewController.swift
//  MyLocations
//
//  Created by Daniel Kwiatkowski on 2015-06-11.
//  Copyright (c) 2015 Daniel Kwiatkowski. All rights reserved.
//

import UIKit
import CoreLocation

private let dateFormatter: NSDateFormatter = {
//in closure because you want to assign the result of the dateFormatter
//create an instance , to take the property of dateStyle and timeStyle properties 
let formatter = NSDateFormatter()
formatter.dateStyle = .MediumStyle
formatter.timeStyle = .ShortStyle
return formatter
}()


class LocationDetailsTableViewController: UITableViewController {
    
    var coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    var placemark: CLPlacemark?
    
    var location:CLLocation?
    
    var descriptionText = ""
    var categoryName = "No Category"
    
    @IBOutlet weak var descripitionTextView:UITextView!
    @IBOutlet weak var categoryLabel:UILabel!
    @IBOutlet weak var latitudeLabel:UILabel!
    @IBOutlet weak var longitudeLabel:UILabel!
    @IBOutlet weak var addressLabel:UILabel!
    @IBOutlet weak var dateLabel:UILabel!
    
    
    @IBAction func done(){
        //this creates a HudView object and adds it to the navigation controller's view with an animation, it also sets the text property on the new object 
        let hudView = HudView.hudInView(navigationController!.view, animated: true)
        hudView.text = "Tagged"
    }
    
    @IBAction func cancel(){
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //edit text from called delegate gets pulled into here
        descripitionTextView.text = descriptionText
        categoryLabel.text = categoryName
        
        latitudeLabel.text = String(format: "%.8f", coordinate.latitude)
        longitudeLabel.text = String(format: "%.8f", coordinate.longitude)
        
        
        if let placemark = placemark{
            addressLabel.text = stringFromPlacemark(placemark)
        } else {
            addressLabel.text = "No Address Found"
        }
        dateLabel.text = formatDate(NSDate())
    
        //helps recognize touches and other finger movements, also is target-design design patterns
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("hideKeyboard:"))
        gestureRecognizer.cancelsTouchesInView = false
        tableView.addGestureRecognizer(gestureRecognizer)
    }
    
    // the layout phase of your view controller when it first appears on the screen, the ideal place for changing frames of your views by hand
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        descripitionTextView.frame.size.width = view.frame.size.width - 30
    }
    
    
    //hide keyboard lets the user tap outside the tableview
    func hideKeyboard(gestureRecognizer: UIGestureRecognizer){
        let point = gestureRecognizer.locationInView(tableView)
        let indexPath = tableView.indexPathForRowAtPoint(point)
        // force unwrap is guaranteed to work because of short-circuiting
        if indexPath != nil && indexPath!.section == 0 && indexPath!.row == 0{
            return
        }
        descripitionTextView.resignFirstResponder()
    }
    
    
    func stringFromPlacemark(placemark:CLPlacemark) -> String{
        return "\(placemark.subThoroughfare) \(placemark.thoroughfare), " + "\(placemark.locality), " + "\(placemark.administrativeArea) \(placemark.postalCode)," + "\(placemark.country)"
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    func formatDate(date:NSDate) -> String{
        println(date)
        return dateFormatter.stringFromDate(date)
    }

    //MARK: - UITableViewDelegate
     override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat{
        if indexPath.section == 0  && indexPath.row == 0{
            return 88
        } else if indexPath.section == 2 && indexPath.row == 2{
            //change the width of screen 115 points less than the width of the screen, //10000 is to make that high, that is done make the rectangle to fit al the text
            addressLabel.frame.size = CGSize(width: view.bounds.size.width - 115, height: 10000)
            //word-wrap the contents of the label
            addressLabel.sizeToFit()
            // this makes your label should be placed against the right edge of the screen with a 15-point margin between them
            addressLabel.frame.origin.x = view.bounds.size.width - addressLabel.frame.size.width - 15
            //we know how high the label is, you can add a margin, 10 points at the bottom and 10 points at the top)
            return addressLabel.frame.size.height + 20
        } else {
            return 44
        }
    }
    
    //limits taps to just the cells from the first two sections because section 3[index 2] is read-only
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        if indexPath.section == 0 || indexPath.section == 1{
            return indexPath
        } else {
            return nil
        }
    }
    //method handles tha actual taps on the rows
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 {
            descripitionTextView.becomeFirstResponder()
        }
    }


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "PickCategory" {
            let controller = segue.destinationViewController as! CategoryPickerViewController
            controller.selectedCategoryName = categoryName
        }
    }
    
    // unwind action method
    @IBAction func categoryPickerDidPickCategory(segue: UIStoryboardSegue){
        let controller = segue.sourceViewController as! CategoryPickerViewController
        
        categoryName = controller.selectedCategoryName
        categoryLabel.text = categoryName
    }
}

// extension for the description text delegate to save info when typing into the text field
extension LocationDetailsTableViewController: UITextViewDelegate{
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool{
        descriptionText = (textView.text as NSString).stringByReplacingCharactersInRange(range, withString: text)
        return true
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        descriptionText = textView.text
    }
}

