//
//  location.swift
//  MyLocations
//
//  Created by Daniel Kwiatkowski on 2015-06-18.
//  Copyright (c) 2015 Daniel Kwiatkowski. All rights reserved.
//

import Foundation
import CoreData
import CoreLocation

class location: NSManagedObject {

    @NSManaged var latitude: Double
    @NSManaged var longitude: Double
    @NSManaged var locationDescription: String
    @NSManaged var category: String
    @NSManaged var placemark: CLPlacemark?
    @NSManaged var date: NSDate
}
