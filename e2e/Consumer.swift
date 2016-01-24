//
//  Category.swift
//  e2e
//
//  Created by José Luis Díaz González on 31/10/15.
//  Copyright © 2015 UPM. All rights reserved.
//

import Foundation
import CoreLocation

class Consumer: NSObject, NSCoding {
  
  let conKey = "consumer"
  var token: String?
  var conID: String?
  var conList:[String] = []
  
  override init() {
    super.init()
    let defaults = NSUserDefaults.standardUserDefaults()
    if defaults.objectForKey(conKey) != nil {
      print("INIT: \(conKey) key exists")
      self.loadConsumer()
    } else {
      self.token = ""
      self.conID = ""
      self.conList.append(self.token!)
      self.conList.append(self.conID!)
      print("INIT: \(conKey) key doesn't exists")
      self.saveConsumer()
    }
  }

  func updateToken(newToken: String) {
    self.conList[0] = newToken
    self.saveConsumer()
    print("UPDATE: Consumer token updated")
    }
  
  func updateID(newID: String) {
    self.conList[1] = newID
    self.saveConsumer()
    print("UPDATE: Consumer ID updated")
    }
  
  required init?(coder aDecoder: NSCoder) {
    token = aDecoder.decodeObjectForKey("token") as? String
  }
  
  func encodeWithCoder(aCoder: NSCoder) {
    aCoder.encodeObject(token, forKey: "token")
  }
  
  func loadConsumer() {
    let defaults = NSUserDefaults.standardUserDefaults()
    if let data = defaults.dataForKey(conKey) {
      if let readList = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? [String] {
        conList = readList
        print("LOAD: \(self.conKey) list loaded with \(self.conList.count) items")
      } else {
        print("ERROR: NSData extraction failed")
        conList = []
      }
    } else {
      print("ERROR: reading key \(conKey) failed")
      conList = []
    }
  }
  
  func saveConsumer() {
    let defaults = NSUserDefaults.standardUserDefaults()
    let myConList = NSKeyedArchiver.archivedDataWithRootObject(self.conList)
    defaults.setObject(myConList, forKey: conKey)
    defaults.synchronize()
    print("SAVE: Consumer saved in \(conKey) key")
  }
  
  func getToken() -> String {
    let defaults = NSUserDefaults.standardUserDefaults()
    if let data = defaults.dataForKey(conKey) {
      if let cList = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? [String] {
        return cList[0]
      } else {
        print("ERROR: NSData extraction failed")
        return "EmptyToken"
      }
    } else {
      print("ERROR: reading key \(conKey) failed")
      return "EmptyToken"
    }
  }
  
  func getConID() -> String {
    let defaults = NSUserDefaults.standardUserDefaults()
    if let data = defaults.dataForKey(conKey) {
      if let cList = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? [String] {
        return cList[1]
      } else {
        print("ERROR: NSData extraction failed")
        return "EmptyID"
      }
    } else {
      print("ERROR: reading key \(conKey) failed")
      return "EmptyID"
    }
  }
  
  func getConsumerJSONData() -> [String: AnyObject] {
    let subsList = SubscriptionList().getSubscriptionsJSONData()
    let blockList = BlockedList().blockedList
    let notiList = NotificationList().notList
    let position = CoreLocationController().currentLocation()
    let data:[String: AnyObject] = ["token": self.getToken(),
            "notifications": [
              "notitype": notiList[1].value!,
              "roaming": notiList[0].value!
            ],
            "location": [
              "longitude":position[0],
              "latitude":position[1]
            ],
            "subscriptions": subsList,
            "blocked": blockList]
//    print(data)
    return data
  }
  
  func getConsumerLocationJSONData() -> [String: AnyObject] {
    let position = CoreLocationController().currentLocation()
    let data:[String: AnyObject] = [
            "location": [
              "longitude":position[0],
              "latitude":position[1]]
            ]
    return data
  }
  
  func getConsumerSubsJSONData() -> [String: AnyObject] {
    let subsList = SubscriptionList().getSubscriptionsJSONData()
//    let blockList = BlockedList().blockedList
    let notiList = NotificationList().notList
    
    let data:[String: AnyObject] = [
            "notifications": [
              "notitype": notiList[1].value!,
              "roaming": notiList[0].value!
            ],
            "subscriptions": subsList,
//            "blocked": blockList
            ]
//    print(data)
    return data
  }
  
}