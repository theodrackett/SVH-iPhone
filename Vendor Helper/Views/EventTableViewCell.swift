//
//  EventableViewCell.swift
//  Vendor Helper
//
//  Created by Theophilus Drackett on 1/5/18.
//  Copyright © 2018 Theophilus Drackett. All rights reserved.
//

import UIKit

class EventTableViewCell: UITableViewCell {
    
    //MARK: Properties
    @IBOutlet weak var eventName: UILabel!
    @IBOutlet weak var RatingControl: RatingControl!
    @IBOutlet weak var eventCatCity: UILabel!
    @IBOutlet weak var numReviews: UILabel!
    @IBOutlet weak var eventImage: UIImageView!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
