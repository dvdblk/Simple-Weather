//
//  Downloader.swift
//  Dvdblk Weather
//
//  Created by David on 10/02/2016.
//  Copyright © 2016 Revion. All rights reserved.
//

import Foundation

class Downloader {
    //let urlList = ["http://api.openweathermap.org/data/2.5/weather?id=3078610&appid=44db6a862fba0b067b1930da0d769e98", "http://api.openweathermap.org/data/2.5/forecast?id=3078610&appid=44db6a862fba0b067b1930da0d769e98"] default API key
    //let urlList = ["http://api.openweathermap.org/data/2.5/weather?id=3078610&appid=137c557bce8219f3a930f1bdb5eaab84", "http://api.openweathermap.org/data/2.5/forecast?id=3078610&appid=137c557bce8219f3a930f1bdb5eaab84"]
    let urlList = ["http://www.dvdblk.com/devel/weather.html", "http://www.dvdblk.com/devel/forecast.html"]
    
    enum Error: ErrorType {
        case HTTPRequestError(String)
        case APIError(String)
    }
    
    typealias CompletionErrorClosure = (error: Error?) -> Void
    
    func fetchUrl(url: String, downloadCompletion: (json: JSON) -> (), downloadFail: (Error) -> ()) {
        let req = NSMutableURLRequest(URL: NSURL(string: url)!)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(req, completionHandler: { (data, response, error) -> Void in
            if let tempErr = error {
                downloadFail(Error.HTTPRequestError(tempErr.localizedDescription))
                return
            }
            let tempResponse = response as! NSHTTPURLResponse
            let tempCode = tempResponse.statusCode
            if tempCode != 200 {
                downloadFail(Error.HTTPRequestError(String(tempCode)))
                return
            }
            downloadCompletion(json: JSON(data: data!))
        })
        task.resume()
    }
    
    func getData(completionHandle: CompletionErrorClosure) {
        // get data and wait for both finished -> Parser -> WeatherData -> NSNotification in didSet
        var completedJSONData: [JSON] = []
        let dispatchGroup = dispatch_group_create()
        var result: Error?
        for url in self.urlList {
            dispatch_group_enter(dispatchGroup)
            self.fetchUrl(url, downloadCompletion: { json in
                completedJSONData.append(json)
                dispatch_group_leave(dispatchGroup)
            }, downloadFail: { err in
                result = err
                dispatch_group_leave(dispatchGroup)
            })
        }
        dispatch_group_notify(dispatchGroup, dispatch_get_main_queue(), { [unowned self] in
            if result != nil {
                completionHandle(error: result)
                return
            }
            self.handleData(completedJSONData, completionHandle: completionHandle)
        })
    }
    
    
    func handleData(rawJsonArr: [JSON], completionHandle: CompletionErrorClosure) {
        func prepareForecastForCurrentHour() -> [JSON]? {
            var result: [JSON] = []
            var tempJSON = rawJsonArr[0]
            if tempJSON["cnt"].int == nil {
                tempJSON = rawJsonArr[1]
                result.append(rawJsonArr[0])
            } else {
                result.append(rawJsonArr[1])
            }
            // fix for different hours probably?
            for i in 0..<tempJSON["cnt"].intValue/8 {
                result.append(tempJSON["list"][6+i*8])
            }
            if result.count == 0 {
                return nil
            }
            return result
        }
        
        func parseAndSave(json: JSON, inout forDay day: OneDayWeather?) -> Error? {
            
            let id = json["weather"][0]["id"].int
            let temperature = json["main"]["temp"].double as Temperature?
            let icon = json["weather"][0]["icon"].string
            let date = json["dt"].int as UnixTime?
            let desc = json["weather"][0]["description"].string
            let tempDay = OneDayWeather(id: id, temp: temperature, icon: icon, date: date, desc: desc)
            
            if day is OneDayWeatherExtended {
                let today = OneDayWeatherExtended()
                today.dataArray.append(dataCell(dblValue: json["clouds"]["all"].double, attributeID: "clouds", "%"))
                today.dataArray.append(dataCell(dblValue: json["main"]["pressure"].double, attributeID: "pressure", "hPa"))
                today.dataArray.append(dataCell(dblValue: json["main"]["humidity"].double, attributeID: "humidity", "%"))
                today.dataArray.append(dataCell(dblValue: json["wind"]["speed"].double, attributeID: "speed", "m/s"))
                today.dataArray.append(dataCell(dblValue: json["wind"]["deg"].double, attributeID: "degrees", ""))
                today.dataArray.append(dataCell(intValue: json["sys"]["sunrise"].int as UnixTime?, attributeID: "sunrise", ""))
                today.dataArray.append(dataCell(intValue: json["sys"]["sunset"].int as UnixTime?, attributeID: "sunset", ""))
                today.dataArray.append(dataCell(dblValue: json["rain"]["3h"].double, attributeID: "rain", "mm"))
                today.dataArray.append(dataCell(dblValue: json["snow"]["3h"].double, attributeID: "snow", "mm"))
                today.dataArray = today.dataArray.filter { $0!.doubleValue != nil || $0!.intValue != nil }.map { $0 }
                day = OneDayWeatherExtended(arr: today.dataArray, baseDay: tempDay)
            } else {
                day = tempDay
            }
            guard let _ = day else {
                return Error.APIError("API Parse Error")
            }
            return nil
        }
        
        guard var tempJSArray = prepareForecastForCurrentHour() else {
            completionHandle(error: Error.APIError("Weather Website Having Trouble..."))
            return
        }
        var result: Error?
        for index in 0..<tempJSArray.count {
            result = parseAndSave(tempJSArray[index], forDay: &WeatherData.sharedInstance.days[index])
            if result != nil { break }
        }
        completionHandle(error: result)
    }
}