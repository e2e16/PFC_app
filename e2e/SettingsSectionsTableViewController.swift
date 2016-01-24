//
//  SettingsSectionsTableViewController.swift
//  e2e
//
//  Created by José Luis Díaz González on 9/11/15.
//  Copyright © 2015 UPM. All rights reserved.
//

import UIKit

class SettingsSectionsTableViewController: UITableViewController {

  @IBOutlet weak var subsCell: UITableViewCell!
  @IBOutlet weak var blocksCell: UITableViewCell!
  @IBOutlet weak var notifCell: UITableViewCell!
 
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    let mySubs = SubscriptionList().totalSubscribed()
    self.subsCell.textLabel?.text = "Suscripciones \t\t\t\t\t\(String(mySubs))"
    self.blocksCell.textLabel?.text = "Bloqueos"
    self.notifCell.textLabel?.text = "Notificaciones"
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(true)
    let mySubs = SubscriptionList().totalSubscribed()
    self.subsCell.textLabel?.text = "Suscripciones \t\t\t\t\t\(String(mySubs))"
  }
  
//  override func viewDidAppear(animated: Bool) {
//    self.tableView.deselectRowAtIndexPath(NSIndexPath(index: 0), animated: true)
//    self.tableView.deselectRowAtIndexPath(NSIndexPath(index: 1), animated: true)
//  }
}

