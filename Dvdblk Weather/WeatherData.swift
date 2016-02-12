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
    var celsius: String {
        let formatter = NSNumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 1
        return "\(formatter.stringFromNumber(round((self - 273.15)*2)/2)!) ℃"
    }
    var kelvin: Temperature { return self }
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
    var speed: Double?
    var degree: Double?
    
    init?(speed: Double?, deg: Double?) {
        if speed == nil { return nil }
        self.speed = speed
        if deg == nil { return nil }
        self.degree = deg
    }
}

struct Sun {
    var rise: UnixTime?
    var set: UnixTime?
    
    init?(rise: UnixTime?, set: UnixTime?) {
        if rise == nil { return nil }
        self.rise = rise
        if set == nil { return nil }
        self.set = set
    }
}

struct Precipitation {
    var rain3h: Double?
    var snow3h: Double?
    
    init?(rain: Double?, snow: Double?) {
        if rain == nil { return nil }
        self.rain3h = rain
        if snow == nil { return nil }
        self.snow3h = snow
    }
}

struct Status {
    var cloudiness: Int?
    var pressure: Double?
    var humidity: Double?
    
    init?(cloud: Int?, press: Double?, humidity: Double?) {
        if cloud == nil { return nil }
        self.cloudiness = cloud
        if press == nil { return nil }
        self.pressure = press
        if humidity == nil { return nil }
        self.humidity = humidity
    }
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
    
    init?(id: Int?, temp: Temperature?, icon: String?, date: UnixTime?) {
        if id == nil { return nil }
        self.id = id
        if temp == nil { return nil }
        self.temperature = temp
        if icon == nil { return nil }
        self.icon = icon
        if date == nil { return nil }
        self.date = date
    }
}

class OneDayWeatherExtended: OneDayWeather {
    var description: String?
    var status: Status?
    var wind: Wind?
    var sun: Sun?
    var precipitation: Precipitation?
    
    override init() {
        self.description = "clear sky"
        super.init()
    }
    
    init?(desc: String?, status: Status?, wind: Wind?, sun: Sun?, preci: Precipitation?, baseDay: OneDayWeather?) {
        super.init(id: baseDay?.id, temp: baseDay?.temperature, icon: baseDay?.icon, date: baseDay?.date)
        if desc == nil { return nil }
        self.description = desc
        if status == nil { return nil }
        self.status = status
        if wind == nil { return nil }
        self.wind = wind
        if sun == nil { return nil }
        self.sun = sun
        self.precipitation = preci
    }
    
    
}

// singleton
class WeatherData {
    static let sharedInstance = WeatherData()
    var days: [OneDayWeather?] = []
    
    private init() {
        days.append(OneDayWeatherExtended())
        for _ in 0..<5 {
            days.append(OneDayWeather())
        }
    }
    
    subscript(index: Int) -> OneDayWeather {
        return days[index]!
    }

}
