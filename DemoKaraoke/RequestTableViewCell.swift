//
//  RequestTableViewCell.swift
//  DemoKaraoke
//
//  Created by Réjean Caron on 17-11-12.
//  Copyright © 2017 Productions Redge. All rights reserved.
//

import UIKit

class RequestTableViewCell: UITableViewCell {
    
    @IBOutlet weak var songLabel: UILabel!
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var singerLabel: UILabel!
    @IBOutlet weak var notesLabel: UILabel!
    @IBOutlet weak var requestTimeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
