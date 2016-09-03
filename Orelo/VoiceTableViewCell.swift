//
//  VoiceTableViewCell.swift
//  Orelo
//
//  Created by sheshkovsky on 15/08/16.
//  Copyright © 2016 Ali Gholami. All rights reserved.
//

import UIKit

class VoiceTableViewCell: UITableViewCell {

    // MARK: Properties
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
