//
//  SubscriptionsList.swift
//  e2e
//
//  Created by José Luis Díaz González on 31/10/15.
//  Copyright © 2015 UPM. All rights reserved.
//

import Foundation

class SubscriptionList {
 
  let subKey = "subscriptions"
  
  var subList: [Subscription] = []
  
  init() {
    let defaults = NSUserDefaults.standardUserDefaults()
    if defaults.objectForKey(subKey) != nil {
      print("INIT: \(subKey) key exists")
      print("INIT: loading contents from \(subKey) list")
      self.loadList()
    } else {
      subList = []
      print("INIT: \(subKey) key doesn't exists")
      print("INIT: creating new empty list and saving in \(subKey) key")
      let myEmptyListData = NSKeyedArchiver.archivedDataWithRootObject(subList)
      defaults.setObject(myEmptyListData, forKey: subKey)
    }
    }
  
  func loadList() {
    let defaults = NSUserDefaults.standardUserDefaults()
    
    if let data = defaults.dataForKey(subKey) {
      if let readList = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? [Subscription] {
        subList = readList
        print("LOAD: \(subKey) list loaded with \(subList.count) items")
      } else {
        print("ERROR: NSData extraction failed")
        subList = []
      }
    } else {
      print("ERROR: reading key \(subKey) failed")
      subList = []
    }
  }
  
  func saveList() {
    let defaults = NSUserDefaults.standardUserDefaults()
    let subListData = NSKeyedArchiver.archivedDataWithRootObject(subList)
    defaults.setObject(subListData, forKey: subKey)
    defaults.synchronize()
    print("SAVE: List saved in \(subKey) key with (\(subList.count) elements)")
  }
  
  func initialSubscriptions() {
    let myCats = CategoryList()
    for cat in myCats.catList {
      self.subList.append(Subscription(name: cat.name!, sub: false))
    }
    self.saveList()
    print("INIT: subscriptions initialized to false")
  }
  
  func totalSubscribed() -> Int {
    var count: Int = 0
    for sub in self.subList {
      if sub.isSub! {
        count++
      }
    }
    return count
  }
  
  func toggleSubscription(subPosition: Int) {
    let mySub = self.subList[subPosition]
    if mySub.isSub! {
      mySub.isSub = false
    } else {
      mySub.isSub = true
    }
    self.subList[subPosition] = mySub
    self.saveList()
    print("SUBS: changed \(mySub.catName!) to \(mySub.isSub!)")
  }
  
  func getSubscriptionsJSONData() -> [String] {
    var mySubsList:[String] = []
    let myCats = CategoryList()
    for sub in self.subList {
      if sub.isSub! {
      mySubsList.append(myCats.getCategoryID(sub.catName!))
//      print("DEBUG: \(sub.catName!) tiene id \(myCats.getCategoryID(sub.catName!))")
      }
    }
    return mySubsList
  }
  
}