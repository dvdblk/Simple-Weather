//
//  CurrentViewController.swift
//  Dvdblk Weather
//
//  Created by David on 07/02/2016.
//  Copyright © 2016 Revion. All rights reserved.
//

import UIKit

class CurrentViewController: UITableViewController {
        
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorStyle = .None
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return WeatherData.sharedInstance.today.dataArray.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Current", forIndexPath: indexPath) as! CurrentCell
        let data = WeatherData.sharedInstance.today.cell(forIndex: indexPath.row)!
        let dataIdentifier = data.attributeIdentifier
        var labelText = data.value!
        let unit = data.unit
        if  unit != "" {
            labelText += " \(unit)"
        }
        //translation
        cell.attributeLabel.text = dataIdentifier
        cell.valueLabel.text = labelText
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
            if let myImage = UIImage(named: dataIdentifier) {
                let tintableImage = myImage.imageWithRenderingMode(.AlwaysTemplate)
                dispatch_async(dispatch_get_main_queue(), {
                    cell.attributeImageView.image = tintableImage
                })
            }
        })
        return cell
    }

}
