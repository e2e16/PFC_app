//
//  Category.swift
//  e2e
//
//  Created by José Luis Díaz González on 31/10/15.
//  Copyright © 2015 UPM. All rights reserved.
//

import Foundation

class Category: NSObject, NSCoding {
  
  var name: String?
  var categoryID: String?
  
  init(catName: String, catID: String) {
    self.name       = catName
    self.categoryID = catID
  }
  
  required init?(coder aDecoder: NSCoder) {
    name       = aDecoder.decodeObjectForKey("name") as? String
    categoryID = aDecoder.decodeObjectForKey("categoryID") as? String
  }
  
  func encodeWithCoder(aCoder: NSCoder) {
    aCoder.encodeObject(name, forKey: "name")
    aCoder.encodeObject(categoryID, forKey: "categoryID")
  }
}