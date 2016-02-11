//
//  WeatherData.swift
//  Dvdblk Weather
//
//  Created by David on 08/02/2016.
//  Copyright © 2016 Revion. All rights reserved.
//

import Foundation

typealias Temperature = Double
typealias UnixTime = Int

extension Temperature {
    var celsius: Temperature { return (self - 32) * 5/9 }
    var fahrenheit: Temperature { return self }
}

extension UnixTime {
    func formatType(form: String) -> NSDateFormatter {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = form
        return dateFormatter
    }
    var dateFull: NSDate {
        return NSDate(timeIntervalSince1970: Double(self))
    }
    var toHour: String {
        return formatType("HH:mm").stringFromDate(dateFull)
    }
    var toDay: String {
        return formatType("EEEE").stringFromDate(dateFull)
    }
}

struct Wind {
    var speed: Double = 0
    var deg: Int = 0
}

struct Sun {
    var rise: UnixTime = 0
    var set: UnixTime = 0
}

struct Status {
    var rain3h: Double?
    var snow3h: Double?
}

class OneDayWeather {
    var id: Int?
    var temperature: Temperature?
    var icon: String?
    var date: UnixTime?
    
    init() {
        self.id = 800
        self.temperature = -460
        self.icon = "01d.png"
        self.date = 0
    }
    
    init(id: Int, temp: Temperature, icon: String, date: UnixTime) {
        self.id = id
        self.temperature = temp
        self.date = date
        self.icon = icon
    }
}

class OneDayWeatherExtended: OneDayWeather {
    var description: String
    var cloudiness: Int
    var pressure: Double
    var humidity: Double
    var wind: Wind?
    var sun: Sun?
    var status: Status?
    
    override init() {
        self.description = "clear sky"
        self.cloudiness = 0
        self.pressure = 1019
        self.humidity = 83
        super.init()
    }
}

// singleton
class WeatherData {
    static let sharedInstance = WeatherData()
    var days: [OneDayWeather] = []
    var today = OneDayWeatherExtended()
    
    private init() {
        for _ in 0..<5 {
            days.append(OneDayWeather())
        }
    }
    
    subscript(index: Int) -> OneDayWeather {
        if index == 0 {
            return today
        } else {
            return days[index-1]
        }
    }
}
