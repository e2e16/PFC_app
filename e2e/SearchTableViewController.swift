//
//  SearchTableViewController.swift
//  e2e
//
//  Created by José Luis Díaz González on 7/11/15.
//  Copyright © 2015 UPM. All rights reserved.
//

import UIKit

class SearchTableViewController: UITableViewController {

  var categoryList = CategoryList()

  override func viewDidLoad() {
    super.viewDidLoad()
    print("VIEW: Search View loaded")
    tableView.reloadData()
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(true)
    navigationController?.setToolbarHidden(true, animated: animated)
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    // Return the number of sections.
    return 1
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    // Return the number of rows in the section.
    return categoryList.catList.count
  }
   override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("CategoryCell", forIndexPath: indexPath) as! SearchTableViewCell
    let category = categoryList.catList[indexPath.row]
    
    cell.catLabel.text = category.name!
    
    return cell
  }
  
  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    let myMessList = MessageList()
    if segue.identifier == "MessageSearchList" {
      if let mstvc = segue.destinationViewController as? MessageSearchTableViewController {
        if let ip = tableView.indexPathForSelectedRow {
          let myCat = categoryList.catList[ip.row]
          myMessList.getMessagesFromServerByCategory(myCat.categoryID!) {(mList) in
               print("DEBUG: \(mList.count) items")
                mstvc.schMessList.messList = mList
            mstvc.tableView.reloadData()
          }
        }
      }
      
    }
    
  }
  
}