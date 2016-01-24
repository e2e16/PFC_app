//
//  PopoverMenuTableViewCell.swift
//  e2e
//
//  Created by José Luis Díaz González on 6/8/15.
//  Copyright (c) 2015 UPM. All rights reserved.
//

import UIKit

class PopoverMenuTableViewCell: UITableViewCell {
  
  @IBOutlet weak var menuItemLabel: UILabel!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }
  
  override func setSelected(selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
}
