//
//  Forecast5Cell.swift
//  Dvdblk Weather
//
//  Created by David on 07/02/2016.
//  Copyright © 2016 Revion. All rights reserved.
//

import UIKit

class Forecast5Cell: UITableViewCell {

    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        dayLabel.text = "Monday"
        self.layoutMargins = UIEdgeInsetsZero
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
