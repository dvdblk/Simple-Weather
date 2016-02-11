//
//  Downloader.swift
//  Dvdblk Weather
//
//  Created by David on 10/02/2016.
//  Copyright © 2016 Revion. All rights reserved.
//

import Foundation

class Downloader {
    let urlList = ["http://api.openweathermap.org/data/2.5/weather?id=3078610&appid=137c557bce8219f3a930f1bdb5eaab84", "http://api.openweathermap.org/data/2.5/forecast?id=3078610&appid=137c557bce8219f3a930f1bdb5eaab84"]
    
    enum Error: ErrorType {
        case HTTPRequestError(Int)
        case APIError(String)
    }
    
    func fetchUrl(url: String, completion: (json: JSON) -> ()) {
        let req = NSMutableURLRequest(URL: NSURL(string: url)!)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(req, completionHandler: { (data, response, error) -> Void in
            var json: JSON?
            guard let tempResponse = response as? NSHTTPURLResponse where tempResponse.statusCode == 200 else {
                print("err")
                return
            }
            json = JSON(data: data!)
            //print(json)
            completion(json: json!)
            //completion(JSON(data: data!))
        })
        task.resume()
    }
    
    func getData() throws -> () {
        // get data and wait for both finished -> Parser -> WeatherData -> NSNotification in didSet
        var completedJSONData: [JSON] = []
        let dispatchGroup = dispatch_group_create()
        
        for url in urlList {
            dispatch_group_enter(dispatchGroup)
            fetchUrl(url, completion: { (json) in
                completedJSONData.append(json)
                dispatch_group_leave(dispatchGroup)
            })
        }
        dispatch_group_wait(dispatchGroup, DISPATCH_TIME_FOREVER)
        try handleData(completedJSONData)
    }
    
    func handleData(rawJsonArr: [JSON]) throws -> () {
        func prepareForecastForCurrentHour(rawJson: JSON) throws -> [JSON] {
            var result: [JSON] = []
            for i in 0..<rawJson["cnt"].intValue/8 {
                result.append(rawJson["list"][6+i*8])
            }
            if result.count == 0 {
                throw Error.APIError("API Having Trouble")
            }
            return result
        }
        
        func parseAndSave(json: JSON, var forDay day: AnyObject) throws -> () {
            day = day as! OneDayWeather
            guard let id = json["weather"][0]["id"].int else {
                throw Error.APIError("weather id")
            }
            guard let temperature = json["main"]["temp"].double as Temperature? else {
                throw Error.APIError("temperature")
            }
            guard let icon = json["weather"][0]["icon"].string else {
                throw Error.APIError("weather icon")
            }
            guard let date = json["dt"].int as UnixTime? else {
                throw Error.APIError("date")
            }
            if day is OneDayWeatherExtended {
                
            } else {
                day = OneDayWeather(id: id, temp: temperature, icon: icon, date: date)
            }
        }
        
        try parseAndSave(rawJsonArr[0], forDay: WeatherData.sharedInstance.today as AnyObject)
        let tempJSArray = try prepareForecastForCurrentHour(rawJsonArr[1])
        for index in 0..<tempJSArray.count {
            try parseAndSave(tempJSArray[index], forDay: WeatherData.sharedInstance.days[index] as AnyObject)
        }
    }
}