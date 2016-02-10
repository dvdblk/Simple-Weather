//
//  Downloader.swift
//  Dvdblk Weather
//
//  Created by David on 10/02/2016.
//  Copyright © 2016 Revion. All rights reserved.
//

import Foundation

class Downloader {
    let urlArray = ["http://api.openweathermap.org/data/2.5/weather?id=3078610&appid=137c557bce8219f3a930f1bdb5eaab84", "http://api.openweathermap.org/data/2.5/forecast?id=3078610&appid=137c557bce8219f3a930f1bdb5eaab84"]
    
    func fetchUrl(url: String, completion: () -> Void) {
        let req = NSMutableURLRequest(URL: NSURL(string: url)!)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(req) { (data, response, error) -> Void in
            completion()
        }
        task.resume()
    }
    
    func getData() {
        // get data and wait for both finished -> Parser -> WeatherData -> NSNotification in didSet
    }
    
}