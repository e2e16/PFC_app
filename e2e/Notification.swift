//
//  Category.swift
//  e2e
//
//  Created by José Luis Díaz González on 31/10/15.
//  Copyright © 2015 UPM. All rights reserved.
//

import Foundation

class Notification: NSObject, NSCoding {
  
  var setting: String?
  var value: Int?
  
  init(conf: String, val: Int) {
    self.setting = conf
    self.value = val
  }
  
  required init?(coder aDecoder: NSCoder) {
    setting       = aDecoder.decodeObjectForKey("setting") as? String
    value = aDecoder.decodeObjectForKey("value") as? Int
  }
  
  func encodeWithCoder(aCoder: NSCoder) {
    aCoder.encodeObject(setting, forKey: "setting")
    aCoder.encodeObject(value, forKey: "value")
  }
}