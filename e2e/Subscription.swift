//
//  Category.swift
//  e2e
//
//  Created by José Luis Díaz González on 31/10/15.
//  Copyright © 2015 UPM. All rights reserved.
//

import Foundation

class Subscription: NSObject, NSCoding {
  
  var catName: String?
  var isSub: Bool?
  
  init(name: String, sub: Bool) {
    self.catName = name
    self.isSub = sub
  }
  
  required init?(coder aDecoder: NSCoder) {
    catName = aDecoder.decodeObjectForKey("catName") as? String
    isSub = aDecoder.decodeObjectForKey("isSub") as? Bool
  }
  
  func encodeWithCoder(aCoder: NSCoder) {
    aCoder.encodeObject(catName, forKey: "catName")
    aCoder.encodeObject(isSub, forKey: "isSub")
  }
}