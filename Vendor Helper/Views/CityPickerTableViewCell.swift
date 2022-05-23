//
//  CityPickerTableViewCell.swift
//  Vendor Helper
//
//  Created by Theophilus Drackett on 1/28/18.
//  Copyright © 2018 Theophilus Drackett. All rights reserved.
//

import UIKit

class CityPickerTableViewCell: UITableViewCell {

    @IBOutlet weak var cityName: UILabel!
    @IBOutlet weak var statePicker: UILabel!
    @IBOutlet weak var homeCity: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
