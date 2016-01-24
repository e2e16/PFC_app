//
//  MessageSearchTableViewController.swift
//  e2e
//
//  Created by José Luis Díaz González on 8/11/15.
//  Copyright © 2015 UPM. All rights reserved.
//

import UIKit

class MessageSearchTableViewController: UITableViewController {

  var schMessList:MessageList = MessageList()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.reloadData()
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(true)
    print("DEBUG: messages loaded \(self.schMessList.messList.count)")
    navigationController?.setToolbarHidden(true, animated: animated)
    tableView.reloadData()
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
    return schMessList.messList.count
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("MessageCell", forIndexPath: indexPath) as! MessageTableViewCell
    
    let message = schMessList.messList[indexPath.row]
    
    cell.producerLabel.text = message.producer!
    cell.alertLabel.text = message.alert!
    cell.deadlineLabel.text = message.deadlineFormatter(false)
    cell.categoryLabel.textColor = UIColor ( red: 0.0, green: 0.665, blue: 0.8383, alpha: 1.0 )
    cell.categoryLabel.text = message.category!
    cell.backgroundColor = UIColor.whiteColor()
    if message.finished == true {
      //cell.contentView.backgroundColor = UIColor ( red: 0.9023, green: 0.9023, blue: 0.9023, alpha: 1.0 )
      cell.deadlineLabel.textColor = UIColor ( red: 0.8467, green: 0.1177, blue: 0.0, alpha: 1.0 )
      cell.backgroundColor = UIColor ( red: 0.9023, green: 0.9023, blue: 0.9023, alpha: 1.0 )
    } else if message.thisWeek == true {
      cell.deadlineLabel.textColor = UIColor ( red: 1.0, green: 0.6057, blue: 0.0, alpha: 1.0 )
    }
    else {
      cell.deadlineLabel.textColor = UIColor ( red: 0.469, green: 0.6513, blue: 0.0, alpha: 1.0 )
    }
    return cell
  }
  
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if segue.identifier == "MessageSearchDetail" {
      if let msdvc = segue.destinationViewController as? MessageSearchDetailViewController {
        if let ip = tableView.indexPathForSelectedRow {
          msdvc.messIndex = ip.row
          msdvc.message = schMessList.messList[ip.row]
        }
      }
      
    }
    
  }
  
}


