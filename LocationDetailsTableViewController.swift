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
        println("Description '\(descriptionText)'")
        dismissViewControllerAnimated(true, completion: nil)
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

