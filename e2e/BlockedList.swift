//
//  SubscriptionsList.swift
//  e2e
//
//  Created by José Luis Díaz González on 31/10/15.
//  Copyright © 2015 UPM. All rights reserved.
//

import Foundation

class BlockedList {
 
  let subKey = "blocked"
  
  var blockedList = []
  
  init() {
    let defaults = NSUserDefaults.standardUserDefaults()
    if defaults.objectForKey(subKey) != nil {
      print("INIT: \(subKey) key exists")
      print("INIT: loading contents from \(subKey) list")
      self.loadList()
    } else {
      blockedList = []
      print("INIT: \(subKey) key doesn't exists")
      print("INIT: creating new empty list and saving in \(subKey) key")
      let myEmptyListData = NSKeyedArchiver.archivedDataWithRootObject(blockedList)
      defaults.setObject(myEmptyListData, forKey: subKey)
    }
    }
  
  func loadList() {
    let defaults = NSUserDefaults.standardUserDefaults()
    
    if let data = defaults.dataForKey(subKey) {
      if let readList = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? [Subscription] {
        blockedList = readList
        print("LOAD: \(subKey) list loaded with \(blockedList.count) items")
      } else {
        print("ERROR: NSData extraction failed")
        blockedList = []
      }
    } else {
      print("ERROR: reading key \(subKey) failed")
      blockedList = []
    }
  }
  
  func saveList() {
    let defaults = NSUserDefaults.standardUserDefaults()
    let blockedListData = NSKeyedArchiver.archivedDataWithRootObject(blockedList)
    defaults.setObject(blockedListData, forKey: subKey)
    defaults.synchronize()
    print("SAVE: List saved in \(subKey) key with (\(blockedList.count) elements)")
  }
}