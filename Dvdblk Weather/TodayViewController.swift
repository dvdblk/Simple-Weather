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
    

    override func viewDidLoad() {
        super.viewDidLoad()
        let myFont = { UIFont(name: "Caviar Dreams", size: $0) }
        temperatureLabel.font = myFont(30)
        statusLabel.font = myFont(25)
        cityLabel.font = myFont(25)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateUI() {
        temperatureLabel.text = WeatherData.sharedInstance.today.temperature?.celsius
        statusLabel.text = WeatherData.sharedInstance.today.description!.capitalizedString
        
        if let myImage = UIImage(named:"\(WeatherData.sharedInstance.today.icon!)") {
            let tintableImage = myImage.imageWithRenderingMode(.AlwaysTemplate)
            weatherImage.image = tintableImage
        }
    }

}
