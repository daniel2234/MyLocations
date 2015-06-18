//
//  Functions.swift
//  MyLocations
//
//  Created by Daniel Kwiatkowski on 2015-06-17.
//  Copyright (c) 2015 Daniel Kwiatkowski. All rights reserved.
//

import Foundation
import Dispatch

//made a seperate function for modular coding
//closure returns from the function
func afterDelay(seconds:Double, closure: () -> ()){
    let when = dispatch_time(DISPATCH_TIME_NOW, Int64(seconds * Double(NSEC_PER_SEC)))
    //tells the app to close the Tag location VC and the closure isnt needed until later
    dispatch_after(when, dispatch_get_main_queue(), closure)
    
}

