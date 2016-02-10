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
    public private(set) var id: Int
    public private(set) var temperature: Temperature
    public private(set) var icon: String?
    public private(set) var date: UnixTime
    
    init() {
        self.id = 800
        self.temperature = 68
        self.date = 0
    }
}

class OneDayWeatherExtended: OneDayWeather {
    public private(set) var description: String
    public private(set) var cloudiness: Int
    public private(set) var pressure: Double
    public private(set) var humidity: Double
    public private(set) var wind: Wind?
    public private(set) var sun: Sun?
    public private(set) var status: Status?
    
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
    var data = [OneDayWeather()]
    
    private init() {
        for _ in 1..<6 {
            data.append(OneDayWeatherExtended())
        }
    }
    
    subscript(index: Int) -> OneDayWeather {
        return data[index]
    }
}
