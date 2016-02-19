//
//  CurrentViewController.swift
//  Dvdblk Weather
//
//  Created by David on 07/02/2016.
//  Copyright © 2016 Revion. All rights reserved.
//

import UIKit

class CurrentViewController: UITableViewController {
    
    var weather: WeatherData!
    
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
        return weather.today.dataArray.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Current", forIndexPath: indexPath) as! CurrentCell
        let data = weather.today.cell(forIndex: indexPath.row)!
        let dataIdentifier = data.attributeIdentifier
        var labelText = data.value!
        let unit = data.unit
        if  unit != "" {
            labelText += " \(unit)"
        }
        cell.attributeLabel.text = dataIdentifier.capitalizedString
        cell.valueLabel.text = labelText
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
            dispatch_async(dispatch_get_main_queue(), {
                cell.attributeImageView.image = UIImage(named: dataIdentifier)!.tintable
            })
        })
        return cell
    }

}
