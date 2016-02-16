//
//  Forecast5ViewController.swift
//  Dvdblk Weather
//
//  Created by David on 08/02/2016.
//  Copyright © 2016 Revion. All rights reserved.
//

import UIKit

class Forecast5ViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorStyle = .None
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return WeatherData.sharedInstance.forecastDayCount
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Forecast5", forIndexPath: indexPath) as! Forecast5Cell
        let day = WeatherData.sharedInstance.days[indexPath.row + 1]
        cell.dayLabel.text = day?.date?.toDay
        cell.temperatureLabel.text = day?.temperature?.celsius
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
            if let myImage = UIImage(named: (day?.icon)!) {
                let tintableImage = myImage.imageWithRenderingMode(.AlwaysTemplate)
                dispatch_async(dispatch_get_main_queue(), {
                    cell.iconImageView.image = tintableImage
                })
            }
        })
        return cell
    }


}
