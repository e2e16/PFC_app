//
//  NotificationsTableViewController.swift
//  e2e
//
//  Created by José Luis Díaz González on 10/11/15.
//  Copyright © 2015 UPM. All rights reserved.
//

import UIKit

class TypeTableViewController: UITableViewController {
  
  @IBOutlet weak var offCell: UITableViewCell!
  @IBOutlet weak var individualCell: UITableViewCell!
  @IBOutlet weak var aggregatedCell: UITableViewCell!
  
  var mySettings: NotificationList?

  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.offCell.textLabel!.text = "apagadas"
    self.individualCell.textLabel!.text = "individuales"
    self.aggregatedCell.textLabel!.text = "agrupadas"
    self.mySettings = NotificationList()
    self.putCheck()
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(true)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func putCheck() {
    for i in 0...self.tableView.numberOfSections-1 {
           for j in 0...self.tableView.numberOfRowsInSection(i)-1 {
                if let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: j, inSection: i)) {
                  if j == self.mySettings!.notList[1].value! {
                      cell.accessoryType = .Checkmark
                  } else {
                      cell.accessoryType = .None
                  }
                  }

                 }

    }}

  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
      self.mySettings?.changeType(indexPath.row)
      self.putCheck()
    }
  
}
