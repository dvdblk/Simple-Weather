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
typealias Degrees = Double


extension NSNumberFormatter {
    func customStringFromNumber(dbl: Double) -> String {
        var result =  self.stringFromNumber(dbl)!
        if result == "-0" { result = "0" }
        result += " °C"
        return result
    }
}

extension Temperature {
    var celsius: String {
        let formatter = NSNumberFormatter()
        formatter.minimumIntegerDigits = 1
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 1
        return formatter.customStringFromNumber(round((self - 273.15)*2)/2)
    }
    var kelvin: Temperature { return self }
}

extension UnixTime {
    func formatType(form: String) -> NSDateFormatter {
        let dateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US")
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

extension Degrees {
    var toCompassPoint: String {
        let directions = ["N", "NE", "E", "SE", "S", "SW", "W", "NW", "N"]
        return directions[Int(round((self%360)/45))]
    }
}

enum DayCycle {
    case Day, Night
    init() {
        self = .Day
    }
    
    mutating func set() {
        let now = Int(NSDate().timeIntervalSince1970)
        let sunr = Int((WeatherData.sharedInstance.today.cell(forAttribute: "sunrise")?.dblValue)!)
        let suns = Int((WeatherData.sharedInstance.today.cell(forAttribute: "sunset")?.dblValue)!)
        //if (now >= sunr) && (now < suns) {
        //    self = .Day
        //} else {
            self = .Night
        //}
    }
}

class OneDayWeather {
    var id: Int?
    var temperature: Temperature?
    var icon: String?
    var date: UnixTime?
    var description: String?
    
    init() {
        self.id = 800
        self.temperature = 0
        self.icon = "01d.png"
        self.date = 0
        self.description = "clear sky"
    }
    
    init?(id: Int?, temp: Temperature?, icon: String?, date: UnixTime?, desc: String?) {
        if id == nil { return nil }
        self.id = id
        if temp == nil { return nil }
        self.temperature = temp
        if icon == nil { return nil }
        self.icon = icon
        if date == nil { return nil }
        self.date = date
        if desc == nil { return nil }
        self.description = desc
    }
}

struct dataCell {
    // try to make it into one value instead of 2 !!! ~~> generics?
    var attributeIdentifier: String = ""
    var unit: String = ""
    var value: String?
    var dblValue: Double?
    
    init?(json: JSON, attributeID: String, _ unit: String, stringFunc :(AnyObject) -> (String)) {
        if let dbl = json.double {
            self.dblValue = dbl
        } else if let dbl = json.int {
            self.dblValue = Double(dbl)
        } else {
            return nil
        }
        self.value = stringFunc(self.dblValue!)
        self.attributeIdentifier = attributeID
        self.unit = unit
    }
}

class OneDayWeatherExtended: OneDayWeather {
    var dataArray: [dataCell?] = []
    
    func cell(forAttribute attr: String) -> dataCell? {
        for data in dataArray {
            if data?.attributeIdentifier == attr {
                return data
            }
        }
        return nil
    }
    
    func cell(forIndex index: Int) -> dataCell? {
        if index >= dataArray.count || index < 0 {
            return nil
        }
        return dataArray[index]
    }
    
    func attribute(forIndex index: Int) -> String {
        return (dataArray[index]?.attributeIdentifier)!
    }
    
    override init() {
        super.init()
    }
    
    init?(arr: [dataCell?], baseDay: OneDayWeather?) {
        super.init(id: baseDay?.id, temp: baseDay?.temperature, icon: baseDay?.icon, date: baseDay?.date, desc: baseDay?.description)
        self.dataArray = arr
    }
    
    
}

// singleton
class WeatherData {
    static let sharedInstance = WeatherData()
    var days: [OneDayWeather?] = []
    var today: OneDayWeatherExtended {
        return days[0] as! OneDayWeatherExtended
    }
    var forecastDayCount: Int {
        let tempArr = days.filter { $0?.temperature != 0 }
        return tempArr.count - 1
    }
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
