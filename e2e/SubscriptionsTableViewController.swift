//
//  SubscriptionsTableViewController.swift
//  e2e
//
//  Created by José Luis Díaz González on 9/11/15.
//  Copyright © 2015 UPM. All rights reserved.
//

import UIKit

class SubscriptionsTableViewController: UITableViewController {
  
  let mySubs = SubscriptionList()
  let myCats = CategoryList()
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
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
    return mySubs.subList.count
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("SubsCell", forIndexPath: indexPath) as! SubscriptionsTableViewCell
  
    let sub = mySubs.subList[indexPath.row]
    
    cell.categoryNameLabel.text = sub.catName!
    cell.catSwitch.setOn(sub.isSub!, animated: true)
    cell.catSwitch.addTarget(self, action: Selector("stateChanged:"), forControlEvents: UIControlEvents.ValueChanged)
    return cell

}
  func stateChanged(sender: UISwitch) {
    let cell = sender.superview!.superview! as! UITableViewCell
    let myIndex = tableView.indexPathForCell(cell)!
    self.mySubs.toggleSubscription(myIndex.row)
    tableView.reloadData()
  }
}