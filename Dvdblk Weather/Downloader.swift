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
        case HTTPRequestError
        case APIError(String)
    }
    
    typealias CompletionErrorClosure = (error: Error?) -> Void
    
    func fetchUrl(url: String, completion: (json: JSON) -> (), fail: () -> ()) {
        let req = NSMutableURLRequest(URL: NSURL(string: url)!)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(req, completionHandler: { (data, response, error) -> Void in
            if error != nil {
                fail()
                return
            }
            guard let tempResponse = response as? NSHTTPURLResponse where tempResponse.statusCode == 200 else {
                fail()
                return
            }
            completion(json: JSON(data: data!))
        })
        task.resume()
    }
    
    func getData(completionHandle: CompletionErrorClosure) {
        // get data and wait for both finished -> Parser -> WeatherData -> NSNotification in didSet
        var completedJSONData: [JSON] = []
        let dispatchGroup = dispatch_group_create()
        for url in self.urlList {
            dispatch_group_enter(dispatchGroup)
            self.fetchUrl(url, completion: { json in
                completedJSONData.append(json)
                dispatch_group_leave(dispatchGroup)
            }, fail: {
                dispatch_group_leave(dispatchGroup)
            })
        }
        dispatch_group_notify(dispatchGroup, dispatch_get_main_queue(), {
            if completedJSONData.count == self.urlList.count {
                self.handleData(completedJSONData, completionHandle: completionHandle)
            } else {
                completionHandle(error: Error.HTTPRequestError)
            }
        })
    }
    
    
    func handleData(rawJsonArr: [JSON], completionHandle: CompletionErrorClosure){
        /*func guardErrors<T: Comparable>(jsonAttributeArray: [T], typeToReturn: AnyObject) -> AnyObject {
            
        }*/
        
        func prepareForecastForCurrentHour(rawJson: JSON) -> [JSON] {
            var result: [JSON] = []
            for i in 0..<rawJson["cnt"].intValue/8 {
                result.append(rawJson["list"][6+i*8])
            }
            if result.count == 0 {
                completionHandle(error: Error.APIError("API Having Trouble"))
            }
            return result
        }
        
        func parseAndSave(json: JSON, var forDay day: AnyObject) {
            day = day as! OneDayWeather
            guard let id = json["weather"][0]["id"].int else {
                completionHandle(error: Error.APIError("weather id"))
                return
            }
            guard let temperature = json["main"]["temp"].double as Temperature? else {
                completionHandle(error: Error.APIError("temperature"))
                return
            }
            guard let icon = json["weather"][0]["icon"].string else {
                completionHandle(error: Error.APIError("weather icon"))
                return
            }
            guard let date = json["dt"].int as UnixTime? else {
                completionHandle(error: Error.APIError("date"))
                return
            }
            if day is OneDayWeatherExtended {
                guard let desc = json["weather"][0]["description"].string else {
                    completionHandle(error: Error.APIError("weather description"))
                    return
                }
                guard let cloudiness = json["weather"][0][""].string else {
                    completionHandle(error: Error.APIError("weather description"))
                    return
                }
            } else {
                day = OneDayWeather(id: id, temp: temperature, icon: icon, date: date)
            }
        }
        
        parseAndSave(rawJsonArr[0], forDay: WeatherData.sharedInstance.today as AnyObject)
        let tempJSArray = prepareForecastForCurrentHour(rawJsonArr[1])
        for index in 0..<tempJSArray.count {
            parseAndSave(tempJSArray[index], forDay: WeatherData.sharedInstance.days[index] as AnyObject)
        }
        completionHandle(error: nil)
    }
}