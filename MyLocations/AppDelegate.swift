//
//  AppDelegate.swift
//  MyLocations
//
//  Created by Daniel Kwiatkowski on 2015-06-09.
//  Copyright (c) 2015 Daniel Kwiatkowski. All rights reserved.
//

import UIKit
import CoreData

let myManagedObjectContextSaveDidFailNotification = "MyManagedObjectContextSaveDidFailNotification"

func fatalCoreDataError(error:NSError?){
    if let error = error {
        println("*** Fatal Error: \(error), \(error.userInfo)")
    }
    NSNotificationCenter.defaultCenter().postNotificationName(myManagedObjectContextSaveDidFailNotification, object: error)
}




@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    // standard code to access core data
    // creates the a lazy instance with variable name managedObjectContext that is an object of type NSManagedObjectContext, very Core Data app uses this
    lazy var managedObjectContext: NSManagedObjectContext = {
        
        //1 Paths and Files are represented as URL by creating a NSURL object
        if let modelURL = NSBundle.mainBundle().URLForResource("DataModel", withExtension: "momd"){
           //2// this object represents the data model at runtime, you ask it what types of entities does it have, what attributes theses entities it has
            if let model = NSManagedObjectModel(contentsOfURL: modelURL){
              //3 this object in charge of the SQLite database
                let coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
              //4 app's data is store in SQL database  inside the app's Documents folder, NSURL object points to the DataStore.sqlite file
                let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
                let documentsDirectory = urls[0] as! NSURL
                let storeURL = documentsDirectory.URLByAppendingPathComponent("Datastore.sqlite")
                //5 Add the SQLite database to the store coordinator
                var error:NSError?
                if let store = coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storeURL, options: nil, error: &error){
                   //6 create a NSManagedObject Context and return it
                    let context = NSManagedObjectContext()
                    context.persistentStoreCoordinator = coordinator
                    println(storeURL)//find the sqlite folder
                    println(documentsDirectory)
                    return context
                //7 debug on the errors and if something went wrong 
                } else {
                    println("Error adding persistent store at \(storeURL): \(error!)")
                }
            } else{
                println("Error initializing model from: \(modelURL)")
            }
        }else{
            println("Could not find data model in app bundle")
        }
        abort()
    }()
    
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        let tabBarController = window!.rootViewController as! UITabBarController
        
        if let tabBarViewControllers = tabBarController.viewControllers{
            let currentLocationViewController = tabBarViewControllers[0] as! CurrentLocationViewController
            
            currentLocationViewController.managedObjectContext = managedObjectContext
        }
        listenForFatalCoreDataNotifications()
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func listenForFatalCoreDataNotifications(){
        //1 tells the NSNotificationCenter that you want to be notified whenever a mymanagedObjectContextsavedidfailnotification is posted, has one argument called notification which contains NSNotification object //wildcard is used just for the closure
        NSNotificationCenter.defaultCenter().addObserverForName(myManagedObjectContextSaveDidFailNotification, object: nil, queue: NSOperationQueue.mainQueue(), usingBlock: { _ in
            //2 Create  a UIAlertcontroller to show the error message
            let alert = UIAlertController(title: "Internal Error", message: "There was a fatal error in the app and it cannot continue.\n\n" + "Press OK to terminate the app. Sorry for the inconvenience.", preferredStyle: .Alert)
            //3 add the action for the OK button, the code for handling the button press is in the closure creates the NSexception object
            let action = UIAlertAction(title: "OK", style: .Default){ _ in
                let exception = NSException(name: NSInternalInconsistencyException, reason: "Fatal Core Data Error", userInfo: nil)
                exception.raise()
            }
            alert.addAction(action)
            //4 present the alert
            self.viewControllerForShowingAlert().presentViewController(alert, animated: true, completion: nil)
            
        })
    }
    
    
//5 to the show the alert, you need a view controller that is currently visible
    func viewControllerForShowingAlert() -> UIViewController{
        let rootViewController = self.window!.rootViewController!
        
        if let presentedViewController = rootViewController.presentedViewController{
            return presentedViewController
        } else {
            return rootViewController
        }
    }
}

