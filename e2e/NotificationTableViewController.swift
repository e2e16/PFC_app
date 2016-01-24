//
//  NotificationsTableViewController.swift
//  e2e
//
//  Created by José Luis Díaz González on 10/11/15.
//  Copyright © 2015 UPM. All rights reserved.
//

import UIKit

class NotificationTableViewController: UITableViewController {
  
  @IBOutlet weak var roamingCell: UITableViewCell!
  @IBOutlet weak var notificationsCell: UITableViewCell!
  @IBOutlet weak var roamingSwitch: UISwitch!
  @IBOutlet weak var notificationsLabel: UILabel!
  
  let mySet = NotificationList()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.notificationsLabel.text = mySet.type2Text()
    self.roamingSwitch.setOn(mySet.getRoamingBool(), animated: true)
    self.roamingSwitch.addTarget(self, action: Selector("stateChanged:"), forControlEvents: UIControlEvents.ValueChanged)
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(true)
    self.roamingSwitch.setOn(mySet.getRoamingBool(), animated: true)
  }
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(true)
    self.notificationsLabel.text = self.mySet.type2Text()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func stateChanged(sender: UISwitch) {
    self.mySet.toggleRoaming()
    tableView.reloadData()
  }
}
