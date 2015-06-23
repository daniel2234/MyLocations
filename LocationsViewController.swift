//
//  LocationsViewController.swift
//  MyLocations
//
//  Created by Daniel Kwiatkowski on 2015-06-23.
//  Copyright (c) 2015 Daniel Kwiatkowski. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation

class LocationsViewController: UITableViewController {
    
    var locations = [Location]()

    var managedObjectContext: NSManagedObjectContext!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //1 
        let fetchRequest = NSFetchRequest()
        //2
        let entity = NSEntityDescription.entityForName("Location", inManagedObjectContext: managedObjectContext)
        fetchRequest.entity = entity
        //3
        let sortDescriptor = NSSortDescriptor(key: "Date", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        //4
        var error:NSError?
        let foundObjects = managedObjectContext.executeFetchRequest(fetchRequest, error: &error)
        
        if foundObjects == nil{
            fatalCoreDataError(error)
            return
        }
        //5
        locations = foundObjects as! [Location]
    }
    
    
    

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1;
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("LocationCell") as! UITableViewCell
        
        let descriptionLabel = cell.viewWithTag(100) as! UILabel
        descriptionLabel.text = "if you are seeinf this"
        
        let addressLabel = cell.viewWithTag(101) as! UILabel
        addressLabel.text = "then you are golden"
        
        return cell
    }
}
