//
//  CoreLocationController.swift
//  e2e
//
//  Created by José Luis Díaz González on 14/11/15.
//  Copyright © 2015 UPM. All rights reserved.
//

import Foundation
import CoreLocation
 
class CoreLocationController : NSObject, CLLocationManagerDelegate {

  var locationManager:CLLocationManager = CLLocationManager()
  var requestManager:RESTRequestController?
 
    override init() {
      super.init()
      self.locationManager.delegate = self
      self.locationManager.requestAlwaysAuthorization()
      self.locationManager.distanceFilter = 50
      self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }
  
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
    print("didChangeAuthorizationStatus")
    
    switch status {
    case .NotDetermined:
      print(".NotDetermined")
      break
      
    case .Authorized:
      print(".Authorized")
      self.locationManager.startUpdatingLocation()
      break
      
    case .Denied:
      print(".Denied")
      break
      
    default:
      print("Unhandled authorization status")
      break
    
    }
  }
  
   func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    
    let location = locations.last
    print("didUpdateLocations:  \(location!.coordinate.latitude), \(location!.coordinate.longitude)")
    requestManager = RESTRequestController(e2eServer: Server().getServer())
    requestManager?.putLocConsumer() {(statCode) in
      if statCode == 200 {
        print("CONSUMER: consumer location successfuly updated in the server")
      } else if statCode == 404 {
        print("ERROR: consumer doesn't exist in the server")
      } else {
        print("ERROR: ERROR")
      }
    }
  }
  
  func currentLocation() -> [Double] {
    return [(locationManager.location?.coordinate.longitude)! as Double, (locationManager.location?.coordinate.latitude)! as Double]
  }
  
}