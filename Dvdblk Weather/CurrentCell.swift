//
//  CurrentCell.swift
//  Dvdblk Weather
//
//  Created by David on 07/02/2016.
//  Copyright © 2016 Revion. All rights reserved.
//

import UIKit

class CurrentCell: UITableViewCell {

    @IBOutlet weak var testLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        testLabel.text = "asd"
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
