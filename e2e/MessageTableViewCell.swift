//
//  MessageTableViewCell.swift
//  e2e
//
//  Created by José Luis Díaz González on 17/7/15.
//  Copyright (c) 2015 UPM. All rights reserved.
//

import UIKit

class MessageTableViewCell: UITableViewCell {
  
  @IBOutlet weak var producerLabel: UILabel!
  @IBOutlet weak var alertLabel: UILabel!
  @IBOutlet weak var deadlineLabel: UILabel!
  @IBOutlet weak var categoryLabel: UILabel!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }
  
  override func setSelected(selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
}
