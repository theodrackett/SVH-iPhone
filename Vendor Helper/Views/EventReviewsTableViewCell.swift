//
//  EventReviewsTableViewCell.swift
//  Street Vendor Helper
//
//  Created by Theophilus Drackett on 1/27/18.
//  Copyright © 2018 Theophilus Drackett. All rights reserved.
//

import UIKit

class EventReviewsTableViewCell: UITableViewCell {
  
    @IBOutlet weak var reviewer: UILabel!
    @IBOutlet weak var reviewerComment: UITextView!
    @IBOutlet weak var reviewerRating: RatingControl!
    @IBOutlet weak var avgEarnings: UILabel!
    @IBOutlet weak var dateRated: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.reviewerComment.layer.borderWidth = 1.0
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
