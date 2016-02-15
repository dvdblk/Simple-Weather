//
//  TodayViewController.swift
//  Dvdblk Weather
//
//  Created by David on 06/02/2016.
//  Copyright © 2016 Revion. All rights reserved.
//

import UIKit

var TEMP_CLOUDS: CGFloat = 0.0

class TodayViewController: UIViewController {
    
    @IBOutlet weak var weatherImage: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
        
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateUI() {
        temperatureLabel.text = WeatherData.sharedInstance.today.temperature?.celsius
        statusLabel.text = WeatherData.sharedInstance.today.description
        weatherImage.image = UIImage(named: "\(WeatherData.sharedInstance.today.icon!)")
    }

    @IBAction func asd(sender: UISlider) {
        TEMP_CLOUDS = CGFloat(sender.value)
        NSNotificationCenter.defaultCenter().postNotificationName("Weather", object: nil)
    }
}
