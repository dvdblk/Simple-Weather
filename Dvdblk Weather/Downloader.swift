//
//  Downloader.swift
//  Dvdblk Weather
//
//  Created by David on 10/02/2016.
//  Copyright © 2016 Revion. All rights reserved.
//

import Foundation

func delay(delay: Double, closure: () -> ()) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), { closure() })
}

class Downloader {
    //44db6a862fba0b067b1930da0d769e98 == default API key
    //let urlList = ["http://api.openweathermap.org/data/2.5/weather?id=3078610&appid=137c557bce8219f3a930f1bdb5eaab84", "http://api.openweathermap.org/data/2.5/forecast?id=3078610&appid=137c557bce8219f3a930f1bdb5eaab84"]
    let urlList = ["http://www.dvdblk.com/devel/weather.html", "http://www.dvdblk.com/devel/forecast.html"]
    
    enum Error: ErrorType {
        case HTTPRequestError(String)
        case APIError(String)
    }
    
    typealias CompletionErrorClosure = (error: Error?) -> Void
    
    func fetchUrl(url: String, downloadCompletion: (json: JSON) -> (), downloadFail: (Error) -> ()) {
        let req = NSMutableURLRequest(URL: NSURL(string: url)!, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 10.0)
        //let req = NSMutableURLRequest(URL: NSURL(string: url)!)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(req, completionHandler: { (data, response, error) -> Void in
            if let tempErr = error {
                downloadFail(Error.HTTPRequestError(tempErr.localizedDescription))
                return
            }
            let tempResponse = response as! NSHTTPURLResponse
            let tempCode = tempResponse.statusCode
            if tempCode != 200 {
                print(tempCode)
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
        dispatch_group_notify(dispatchGroup, dispatch_get_main_queue(), {
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
                today.dataArray.append(dataCell(json: json["clouds"]["all"], attributeID: "cloudiness", "%", stringFunc: json.myString))
                today.dataArray.append(dataCell(json: json["main"]["pressure"], attributeID: "pressure", "hPa", stringFunc: json.myString))
                today.dataArray.append(dataCell(json: json["main"]["humidity"], attributeID: "humidity", "%", stringFunc: json.myString))
                today.dataArray.append(dataCell(json: json["wind"]["speed"], attributeID: "wind speed", "m/s", stringFunc: json.myString))
                today.dataArray.append(dataCell(json: json["wind"]["deg"], attributeID: "wind direction", "", stringFunc: json.myDegrees))
                today.dataArray.append(dataCell(json: (json["sys"]["sunrise"]), attributeID: "sunrise", "", stringFunc: json.myTime))
                today.dataArray.append(dataCell(json: json["sys"]["sunset"], attributeID: "sunset", "", stringFunc: json.myTime))
                today.dataArray.append(dataCell(json: json["rain"]["3h"], attributeID: "rain (3h)", "mm", stringFunc: json.myString))
                today.dataArray.append(dataCell(json: json["snow"]["3h"], attributeID: "snow (3h)", "mm", stringFunc: json.myString))
                today.dataArray = today.dataArray.filter { $0?.dblValue != nil }.map { $0 }
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

extension JSON {
    public func myDegrees(dbl: AnyObject) -> String {
        let temp = dbl as! Degrees
        return temp.toCompassPoint
    }

    public func myTime(dbl: AnyObject) -> String {
        let time = dbl as! UnixTime
        return time.toHour
    }
    
    public func myString(dbl: AnyObject) -> String {
        let formatter = NSNumberFormatter()
        formatter.minimumIntegerDigits = 1
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 1
        let tempDbl = dbl as! Double
        return formatter.stringFromNumber(tempDbl)!
    }
}