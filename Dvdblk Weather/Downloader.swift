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
        case HTTPRequestError(String)
        case APIError(String)
    }
    
    typealias CompletionErrorClosure = (error: Error?) -> Void
    
    func fetchUrl(url: String, downloadCompletion: (json: JSON) -> (), downloadFail: (Error) -> ()) {
        let req = NSMutableURLRequest(URL: NSURL(string: url)!, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData, timeoutInterval: 10.0)
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
    
    
    func handleData(rawJsonArr: [JSON], completionHandle: CompletionErrorClosure){
        /*func guardErrors<T: Comparable>(jsonAttributeArray: [T], typeToReturn: AnyObject) -> AnyObject {
            
        }*/
        
        func prepareForecastForCurrentHour(rawJson: JSON) -> [JSON]? {
            var result: [JSON] = []
            for i in 0..<rawJson["cnt"].intValue/8 {
                result.append(rawJson["list"][6+i*8])
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
            let tempDay = OneDayWeather(id: id, temp: temperature, icon: icon, date: date)
            
            if day is OneDayWeatherExtended {
                let desc = json["weather"][0]["description"].string
                let cloudiness = json["clouds"]["all"].int
                let pressure = json["main"]["pressure"].double
                let humidity = json["main"]["humidity"].double
                let windSpeed = json["wind"]["speed"].double
                let windDeg = json["wind"]["deg"].double
                let sunrise = json["sys"]["sunrise"].int as UnixTime?
                let sunset = json["sys"]["sunset"].int as UnixTime?
                let rain = json["rain"]["3h"].double
                let snow = json["snow"]["3h"].double

                let status = Status(cloud: cloudiness, press: pressure, humidity: humidity)
                let wind = Wind(speed: windSpeed, deg: windDeg)
                let sun = Sun(rise: sunrise, set: sunset)
                let precipitation = Precipitation(rain: rain, snow: snow)
                day = OneDayWeatherExtended(desc: desc, status: status, wind: wind, sun: sun, preci: precipitation, baseDay: tempDay)
            } else {
                day = tempDay
            }
            guard let _ = day else {
                return Error.APIError("API Parse Error")
            }
            return nil
        }
        
        guard var tempJSArray = prepareForecastForCurrentHour(rawJsonArr[1]) else {
            completionHandle(error: Error.APIError("WeatherAPI Website Having Trouble..."))
            return
        }
        tempJSArray.insert(rawJsonArr[0], atIndex: 0)
        var result: Error?
        for index in 0..<tempJSArray.count {
            result = parseAndSave(tempJSArray[index], forDay: &WeatherData.sharedInstance.days[index])
            if result != nil { break }
        }
        completionHandle(error: result)
    }
}