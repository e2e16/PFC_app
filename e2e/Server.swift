//
//  Category.swift
//  e2e
//
//  Created by José Luis Díaz González on 31/10/15.
//  Copyright © 2015 UPM. All rights reserved.
//

import Foundation

class Server: NSObject, NSCoding {
  
  var address: String?
  let serverKey = "server"
  
  override init() {
    
  }
  
  init(addss: String) {
    self.address = addss
    let defaults = NSUserDefaults.standardUserDefaults()
    if defaults.objectForKey(serverKey) != nil {
      print("INIT: \(serverKey) key exists")
    } else {
      print("INIT: \(serverKey) key doesn't exists")
      print("INIT: creating new default server and saving in \(serverKey) key")
      defaults.setObject(NSKeyedArchiver.archivedDataWithRootObject(self.address!), forKey: serverKey)
    }
  }
  
  required init?(coder aDecoder: NSCoder) {
    address = aDecoder.decodeObjectForKey("address") as? String
  }
  
  func encodeWithCoder(aCoder: NSCoder) {
    aCoder.encodeObject(address, forKey: "address")
  }
  
  func getServer() -> String {
    let defaults = NSUserDefaults.standardUserDefaults()
    if let data = defaults.dataForKey(serverKey) {
      if let myServer = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? String {
        print("LOAD: server loaded")
        return myServer
      } else {
        print("ERROR: NSData extraction failed")
        return "localhost"
      }
    } else {
      print("ERROR: reading key server failed")
      return "localhost"
    }
  }
  
  func updateServer(addss: String) {
    let defaults = NSUserDefaults.standardUserDefaults()
    let server = NSKeyedArchiver.archivedDataWithRootObject(addss)
    defaults.setObject(server, forKey: serverKey)
    defaults.synchronize()
    print("SAVE: new server address saved")
  }
  
  func isServerAlive(completionHandler: (Bool) -> ()) {
    let url = NSURL(string: "http://\(self.getServer())/e2e")
    let request = NSMutableURLRequest(URL: url!)
    request.HTTPMethod = "HEAD"
    request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringLocalAndRemoteCacheData
    request.timeoutInterval = 10.0
    let session = NSURLSession.sharedSession()

    session.dataTaskWithRequest(request) {(data, response, error) in
//      print("data \(data)")
//      print("response \(response)")
//      print("error \(error)")
      print("SERVER: checking if server is alive")
   
      if (error != nil) {
        completionHandler(false)
      }
    

      if let httpResponse = response as? NSHTTPURLResponse {
          print("RESPONSE: httpResponse.statusCode \(httpResponse.statusCode)")
          if httpResponse.statusCode == 200 {
            completionHandler(true)
          } else {
            completionHandler(false)
        }
      }

    }.resume()
    }
}