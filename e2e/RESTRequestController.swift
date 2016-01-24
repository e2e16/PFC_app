//
//  RESTRequestController.swift
//  e2e
//
//  Created by José Luis Díaz González on 7/11/15.
//  Copyright © 2015 UPM. All rights reserved.
//

import Foundation

class RESTRequestController {
  
  var baseUrl = "http://196.168.6.6:3000"
  var myConsumer = Consumer()
  
  init() {
  }
  
  init(e2eServer: String) {
    self.baseUrl = "http://\(e2eServer)"
    
  }

  func getCategories(completionHandler: (NSArray) -> ()) {
    let url = NSURL(string: "\(baseUrl)/e2e/categories")
    let request = NSURLRequest(URL: url!)
    let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {(data, response, error) in
      if error != nil {
        print(error!)
      } else {
      do {
        let categories = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? NSArray
        completionHandler(categories!)
        return
      } catch {
        print(error)
        print("JSON: ERROR trying to convert data to JSON")
        return
      }
      }
      }
    task.resume()
  }
  
  func getMessagesByCategory(catID: String, completionHandler: ([AnyObject]) -> ()) {
    let url = NSURL(string: "\(baseUrl)/e2e/categories/\(catID)/messages")
    let request = NSURLRequest(URL: url!)
    let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {(data, response, error) in
      if error != nil {
        print(error!)
      } else {
      do {
//        print(NSString(data: data!, encoding: NSUTF8StringEncoding))
        let messages = try NSJSONSerialization.JSONObjectWithData(data!, options: [.AllowFragments, .MutableContainers]) as? [AnyObject]
        completionHandler(messages!)
        return
      } catch {
        print(error)
        print("JSON: ERROR trying to convert data to JSON")
        return
      }
      }
      }
    task.resume()
  }
  
  func postConsumer(completionHandler: (Int, String) -> ()) {
    let myJSONConsumer = myConsumer.getConsumerJSONData()
    let url = NSURL(string: "\(baseUrl)/e2e/consumers")
    let request = NSMutableURLRequest(URL: url!)
    request.HTTPMethod = "POST"
    do {
      request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(myJSONConsumer, options: [])
    } catch {
      print(error)
    }
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//    request.addValue("application/json", forHTTPHeaderField: "Accept")
    
    let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {(data, response, error) in
      var conID:String = ""
      if error != nil {
        print(error!)
      } else {
      do {
        let result = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? NSDictionary
        print(result!["message"] as! String)
        if let resData = result!["data"]?["_id"] as? String {
          print("DEBUG: \(resData)")
          conID = resData
        } else {
          conID = ""
        }
        
      } catch {
        print("JSON: ERROR trying to convert data to JSON")
        }}
      if let httpResponse = response as? NSHTTPURLResponse {
        completionHandler(httpResponse.statusCode, conID)
      }
    }
    task.resume()
  }
  
  func putLocConsumer(completionHandler: (Int) -> ()) {
    let myJSONConsumer = myConsumer.getConsumerLocationJSONData()
    let url = NSURL(string: "\(baseUrl)/e2e/consumers/\(myConsumer.getConID())/location")
    let request = NSMutableURLRequest(URL: url!)
    request.HTTPMethod = "PUT"
    do {
      request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(myJSONConsumer, options: [])
    } catch {
      print(error)
    }
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//    request.addValue("application/json", forHTTPHeaderField: "Accept")
    
    let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {(data, response, error) in
      if error != nil {
        print(error!)
      } else {
      do {
        let result = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? NSDictionary
        print(result!["message"] as! String)
        return
      } catch {
        print("JSON: ERROR trying to convert data to JSON")
        return
      }
      }
      if let httpResponse = response as? NSHTTPURLResponse {
        completionHandler(httpResponse.statusCode)
        return
      }
    }
    task.resume()
  }
  
  func putSubsConsumer(completionHandler: (Int) -> ()) {
    let myJSONConsumer = myConsumer.getConsumerSubsJSONData()
    let url = NSURL(string: "\(baseUrl)/e2e/consumers/\(myConsumer.getConID())/subscription")
    let request = NSMutableURLRequest(URL: url!)
    request.HTTPMethod = "PUT"
    do {
      request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(myJSONConsumer, options: [])
    } catch {
      print(error)
    }
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//    request.addValue("application/json", forHTTPHeaderField: "Accept")
    
    let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {(data, response, error) in
      if error != nil {
        print(error!)
      } else {
      do {
        let result = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? NSDictionary
        print(result!["message"] as! String)
      } catch {
        print("JSON: ERROR trying to convert data to JSON")
        }}
      if let httpResponse = response as? NSHTTPURLResponse {
        completionHandler(httpResponse.statusCode)
      }
    }
    task.resume()
  }
}