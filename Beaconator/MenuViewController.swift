//
//  ViewController.swift
//  Beaconator
//
//  Created by vparrella on 11/3/14.
//  Copyright (c) 2014 vparrella. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController, AuthorizationViewControllerDelegate {

    let kLastCreateLocationKey = "lastCreatedLocationKey"
    
    func showLocationSetup() {
        weak var weakSelf:MenuViewController? = self
        
        let locationSetupVC = ESTIndoorLocationManager.locationSetupControllerWithCompletion { (location, error) in
            weakSelf!.dismissViewControllerAnimated(true, completion: nil)
            
            if let newLocation = location {
                NSUserDefaults.standardUserDefaults().setObject(location.toDictionary(), forKey: self.kLastCreateLocationKey)
                weakSelf!.loadLocation()
            }
        }
        
        self.presentViewController(UINavigationController(rootViewController: locationSetupVC),
            animated: true,
            completion: nil)
    }
    
    @IBAction func setupNewLocation() {
        if !ESTIndoorLocationManager.isAuthorized() {
            var authorizationViewController:AuthorizationViewController = AuthorizationViewController()
            authorizationViewController.delegate = self
            
            self.presentViewController(UINavigationController(rootViewController: authorizationViewController), animated: true, completion: nil)
        } else {
            self.showLocationSetup()
        }
    }
    
    @IBAction func loadLocation() {
        let dictionaryLocationRepresentation:NSDictionary? = NSUserDefaults.standardUserDefaults().objectForKey(self.kLastCreateLocationKey) as? NSDictionary
        
        if let dict = dictionaryLocationRepresentation {
            let location = ESTLocation(fromDictionary: dictionaryLocationRepresentation)
            var locationViewController = LocationViewController(nibName: "LocationViewController", bundle: nil)
            locationViewController.location = location
            self.navigationController?.pushViewController(locationViewController, animated: true)
        }
        else {
            let alertView = UIAlertView(title: "No saved location", message: "Setup a new location first", delegate: nil, cancelButtonTitle: "OK")
            alertView.show()
        }
    }
    
    //MARK: AuthorizationViewController delegate
    func authorizationEnded(error: NSError?) {
        if (error == nil) {
            
            weak var weakSelf:MenuViewController? = self
            dispatch_after(1, dispatch_get_main_queue(), {
                weakSelf!.showLocationSetup()
            })
        }
    }


}

