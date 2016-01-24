//
//  SubscriptionsList.swift
//  e2e
//
//  Created by José Luis Díaz González on 31/10/15.
//  Copyright © 2015 UPM. All rights reserved.
//

import Foundation

class CategoryList {
 
  let catKey = "categories"
  
  var catList: [Category] = []
  
  init() {
    let defaults = NSUserDefaults.standardUserDefaults()
    if defaults.objectForKey(catKey) != nil {
      print("INIT: \(catKey) key exists")
      print("INIT: loading contents from \(catKey) list")
      self.loadList()
    } else {
      catList = []
      print("INIT: \(catKey) key doesn't exists")
      print("INIT: creating new empty list and saving in \(catKey) key")
      let myEmptyListData = NSKeyedArchiver.archivedDataWithRootObject(catList)
      defaults.setObject(myEmptyListData, forKey: catKey)
    }
    }
  
  func loadList() {
    let defaults = NSUserDefaults.standardUserDefaults()
    
    if let data = defaults.dataForKey(catKey) {
      if let readList = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? [Category] {
        catList = readList
        print("LOAD: \(catKey) list loaded with \(catList.count) items")
      } else {
        print("ERROR: NSData extraction failed")
        catList = []
      }
    } else {
      print("ERROR: reading key \(catKey) failed")
      catList = []
    }
  }
  
  func saveList() {
    let defaults = NSUserDefaults.standardUserDefaults()
    let catListData = NSKeyedArchiver.archivedDataWithRootObject(catList)
    defaults.setObject(catListData, forKey: catKey)
    defaults.synchronize()
    print("SAVE: List saved in \(catKey) key with (\(catList.count) elements)")
  }
  
  func updateListFromServer() {
    let req = RESTRequestController(e2eServer: Server().getServer())
    req.getCategories() { (cats) in
      var myTempList:[Category] = []
      for cat in cats {
        myTempList.append(Category(catName: cat["name"] as! String, catID: cat["_id"] as! String))
      }
      self.catList = myTempList
      self.saveList()
    }
  }
  
  func addCategory(cat: Category) {
    catList.insert(cat, atIndex: 0)
    print("ASS: category \(cat.categoryID!) added")
  }
  
  func deleteCategory(catIndex: Int) {
    print("DELETE: category \(catList[catIndex].categoryID!) at index \(catIndex) deleted")
    catList.removeAtIndex(catIndex)
  }
  
  func existCategory(catID: String) -> Bool {
    for cat in catList {
      if cat.categoryID! == catID {
        print("EXIST: category \(catID) already exists")
        return true
      }
    }
    print("EXIST: category \(catID) doesn't exist")
    return false
  }
  
  func getCategoryID(categoryName: String) -> String {
    for cat in catList {
      if cat.name! == categoryName {
        return cat.categoryID!
      } else {
        continue
      }
    }
    return ""
  }
  
}