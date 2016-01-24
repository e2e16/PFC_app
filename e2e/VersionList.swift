//
//  File.swift
//  e2e
//
//  Created by José Luis Díaz González on 7/11/15.
//  Copyright © 2015 UPM. All rights reserved.
//

import Foundation

class VersionList {
  
  let verKey = "versions"
  
  var verList: [Version] = []
  
  init() {
    let defaults = NSUserDefaults.standardUserDefaults()
    if defaults.objectForKey(verKey) != nil {
      print("INIT: \(verKey) key exists")
      print("INIT: loading contents from \(verKey) list")
    } else {
      print("INIT: \(verKey) key doesn't exists")
      print("INIT: creating new empty list and saving in \(verKey) key")
      verList.append(Version(myKey: "catVersion", myValue: "0.0"))
      verList.append(Version(myKey: "protoVersion", myValue: "1.0"))
      let myInitialListData = NSKeyedArchiver.archivedDataWithRootObject(verList)
      defaults.setObject(myInitialListData, forKey: verKey)
      print("INIT: Version list initialized")
    }
  }
  
  func loadList() {
      let defaults = NSUserDefaults.standardUserDefaults()
      if let data = defaults.dataForKey(self.verKey) {
        if let readList = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? [Version] {
          verList = readList
          print("LOAD: \(verKey) list loaded with \(verList.count) items")
        } else {
          print("ERROR: NSData extraction failed")
          verList = []
        }
      } else {
        print("ERROR: reading key \(verKey) failed")
        verList = []
      }
  }
  
  func updateVersions(newVersions:[Version]) {
    let defaults = NSUserDefaults.standardUserDefaults()
    self.verList = newVersions
    let verListData = NSKeyedArchiver.archivedDataWithRootObject(verList)
    defaults.setObject(verListData, forKey: verKey)
    defaults.synchronize()
    print("SAVE: List saved in \(verKey) key with (\(verList.count) elements)")
  }
  
}