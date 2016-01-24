//
//  PopoverMenuTableViewController.swift
//  e2e
//
//  Created by José Luis Díaz González on 6/8/15.
//  Copyright (c) 2015 UPM. All rights reserved.
//

import UIKit

class PopoverMenuTableViewController: UITableViewController {
  
  var menuItems: [String] = []
  var popoverMenu: MessageTableViewController.topMenu?
  var popoverMenuSelection: Int?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = false
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    
    //self.tableView.tableFooterView = UIView(frame: CGRectZero)
    
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  // MARK: - Table view data source
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    // #warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    // #warning Incomplete method implementation.
    // Return the number of rows in the section.
    return self.menuItems.count
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("menuCell", forIndexPath: indexPath) as! PopoverMenuTableViewCell
    
    let itemMenu = self.menuItems[indexPath.row]
    
    switch popoverMenu! {
    case .Clean:
      cell.menuItemLabel.textColor = UIColor ( red: 1.0, green: 0.366, blue: 0.3337, alpha: 1.0 )
      tableView.scrollEnabled = false
    case .Filter:
      switch indexPath.row {
      case 0:
        cell.menuItemLabel.textColor = view.tintColor
      default:
        cell.menuItemLabel.textColor = UIColor ( red: 0.6713, green: 0.3169, blue: 0.8382, alpha: 1.0 )
      }
      tableView.scrollEnabled = true
      tableView.showsVerticalScrollIndicator = true
      tableView.alwaysBounceVertical = true
    default: ()
    }
    
    cell.menuItemLabel.text = itemMenu
    cell.preservesSuperviewLayoutMargins = false
    cell.layoutMargins = UIEdgeInsetsZero
    
    return cell
  }
  
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    dismissViewControllerAnimated(true, completion: nil)
    performSegueWithIdentifier("PopoverMenu", sender: self)
  }
  
  
  
  /*
  // Override to support conditional editing of the table view.
  override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
  // Return NO if you do not want the specified item to be editable.
  return true
  }
  */
  
  /*
  // Override to support editing the table view.
  override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
  if editingStyle == .Delete {
  // Delete the row from the data source
  tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
  } else if editingStyle == .Insert {
  // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
  }
  }
  */
  
  /*
  // Override to support rearranging the table view.
  override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
  
  }
  */
  
  /*
  // Override to support conditional rearranging of the table view.
  override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
  // Return NO if you do not want the item to be re-orderable.
  return true
  }
  */
  
  // MARK: - Navigation
  
  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "PopoverMenu" {
      if let mtvc = segue.destinationViewController as? MessageTableViewController {
        if let ip = tableView.indexPathForSelectedRow {
          mtvc.menuSelectionIndex = ip.row
          mtvc.menuPopover = popoverMenu!
        }
      }
    }
  }
}