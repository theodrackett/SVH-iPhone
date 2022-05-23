//
//  MiniTableViewCell.swift
//  Street Vendor Helper
//
//  Created by Theo Drackett on 12/4/19.
//  Copyright © 2019 Theophilus Drackett. All rights reserved.
//

import UIKit

class MiniTableViewCell: UITableViewCell {

    @IBOutlet weak var commentBubble: UIView!
    @IBOutlet weak var vendorName: UILabel!
    @IBOutlet weak var MiniRatingControl: RatingControl!
    @IBOutlet weak var vendorComment: UITextView!
    @IBOutlet weak var avgEarningLabel: UILabel!
    @IBOutlet weak var dateRatedLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
//        commentBubble.layer.cornerRadius = commentBubble.frame.size.height / 5
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
