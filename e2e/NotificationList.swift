//
//  SubscriptionsList.swift
//  e2e
//
//  Created by José Luis Díaz González on 31/10/15.
//  Copyright © 2015 UPM. All rights reserved.
//

import Foundation

class NotificationList {
 
  let notKey = "notifications"
  
  var notList: [Notification] = []
  
  init() {
    let defaults = NSUserDefaults.standardUserDefaults()
    if defaults.objectForKey(notKey) != nil {
      print("INIT: \(notKey) key exists")
      print("INIT: loading contents from \(notKey) list")
      self.loadList()
    } else {
      notList = []
      print("INIT: \(notKey) key doesn't exists")
      print("INIT: creating new empty list and saving in \(notKey) key")
      let myEmptyListData = NSKeyedArchiver.archivedDataWithRootObject(notList)
      defaults.setObject(myEmptyListData, forKey: notKey)
    }
      self.loadList()
    }
  
  func loadList() {
    let defaults = NSUserDefaults.standardUserDefaults()
    
    if let data = defaults.dataForKey(notKey) {
      if let readList = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? [Notification] {
        notList = readList
        print("LOAD: \(notKey) list loaded with \(notList.count) items")
      } else {
        print("ERROR: NSData extraction failed")
        notList = []
      }
    } else {
      print("ERROR: reading key \(notKey) failed")
      notList = []
    }
  }
  
  func getRoamingBool() -> Bool {
    if notList[0].value == 0 {
      return false
    } else {
      return true
    }
  }
  
  func saveList() {
    let defaults = NSUserDefaults.standardUserDefaults()
    let notListData = NSKeyedArchiver.archivedDataWithRootObject(notList)
    defaults.setObject(notListData, forKey: notKey)
    defaults.synchronize()
    print("SAVE: List saved in \(notKey) key with (\(notList.count) elements)")
  }
  
  func initialConfig() {
    if self.notList.count == 0 {
      self.notList.append(Notification(conf: "roaming", val: 0))
      self.notList.append(Notification(conf: "type", val: 1))
      print("INIT: notifications initilized to: roaming 0, type 1")
      self.saveList()
    } else {
      print("INIT: notifications already initilized")
    }
  }
  
  func toggleRoaming() {
    if notList[0].value == 0 {
      notList[0].value = 1
    } else {
      notList[0].value = 0
    }
    print("NOTIF: roaming setting toggle to \(notList[0].value!)")
    self.saveList()
  }
  
  func changeType(newType: Int) {
    notList[1].value = newType
    self.saveList()
  }
  
  func type2Text() -> String {
    self.loadList()
    switch self.notList[1].value! {
    case 0:
      return "apagadas"
    case 1:
      return "individuales"
    case 2:
      return "agrupadas"
    default:
      return "error"
    }
  }
  
  func getNotificationsJSONData() -> [NSDictionary] {
    var myNotis:[NSDictionary] = []
    myNotis.append(NSDictionary(object: self.notList[1].value!, forKey: "notitype"))
    myNotis.append(NSDictionary(object: self.notList[0].value!, forKey: "roaming"))
    return myNotis
    
  }
  
}