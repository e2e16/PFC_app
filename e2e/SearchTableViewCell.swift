//
//  SearchTableViewCell.swift
//  e2e
//
//  Created by José Luis Díaz González on 7/11/15.
//  Copyright © 2015 UPM. All rights reserved.
//

import UIKit

class SearchTableViewCell: UITableViewCell {

  @IBOutlet weak var catLabel: UILabel!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }
  
  override func setSelected(selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
}
