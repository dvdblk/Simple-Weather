//
//  TodayViewController.swift
//  Dvdblk Weather
//
//  Created by David on 06/02/2016.
//  Copyright © 2016 Revion. All rights reserved.
//

import UIKit

class TodayViewController: UIViewController {
    
    @IBOutlet weak var weatherImage: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    
    var weather: WeatherData!

    override func viewDidLoad() {
        super.viewDidLoad()
        let myFont = { UIFont(name: "Caviar Dreams", size: $0) }
        temperatureLabel.font = myFont(30)
        statusLabel.font = myFont(25)
        cityLabel.font = myFont(25)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func updateData() {
        temperatureLabel.text = weather.today.temperature?.celsius
        statusLabel.text = weather.today.description!.capitalizedString
        weatherImage.image = UIImage(named: weather.today.icon!)!.tintable
    }

}
