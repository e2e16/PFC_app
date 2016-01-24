//
//  Category.swift
//  e2e
//
//  Created by José Luis Díaz González on 31/10/15.
//  Copyright © 2015 UPM. All rights reserved.
//

import Foundation

class Version: NSObject, NSCoding {
  
  var version: NSDictionary?
  
  init(myKey: String, myValue: String) {
    self.version = ["myKey":"myValue"]
  }
  
  required init?(coder aDecoder: NSCoder) {
    version = aDecoder.decodeObjectForKey("version") as? NSDictionary
  }
  
  func encodeWithCoder(aCoder: NSCoder) {
    aCoder.encodeObject(version, forKey: "version")
  }
}