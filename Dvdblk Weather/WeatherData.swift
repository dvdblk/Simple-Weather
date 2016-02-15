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
        formatter.minimumIntegerDigits = 1
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

enum DayCycle {
    case Day, Night
    init() {
        self = .Day
    }
    
    mutating func set() {
        let now = Int(NSDate().timeIntervalSince1970)
        let sunr = WeatherData.sharedInstance.today.cell(forAttribute: "sunrise")?.intValue
        let suns = WeatherData.sharedInstance.today.cell(forAttribute: "sunset")?.intValue
        //if (now >= sunr) && (now < suns) {
            self = .Day
        //} else {
        //    self = .Night
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
    var intValue: UnixTime?
    var doubleValue: Double?

    init?(intValue: UnixTime?, attributeID: String, _ unit: String) {
        self.intValue = intValue
        self.attributeIdentifier = attributeID
        self.unit = unit
    }
    
    init?(dblValue: Double?, attributeID: String, _ unit: String) {
        self.doubleValue = dblValue
        self.attributeIdentifier = attributeID
        self.unit = unit
    }
}

class OneDayWeatherExtended: OneDayWeather {
    var dataArray: [dataCell?] = []
    
    func cellString(forAttribute attr: String) -> String {
        let data = cell(forAttribute: attr)
        let formatter = NSNumberFormatter()
        formatter.minimumIntegerDigits = 1
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 1
        let result = data!.intValue
        if result == nil {
            return "\(formatter.stringFromNumber(data!.doubleValue!)!) \(data!.unit)"
        }
        return result!.toHour
    }
    
    func cell(forAttribute attr: String) -> dataCell? {
        for data in dataArray {
            if data?.attributeIdentifier == attr {
                return data
            }
        }
        return nil
    }
    
    func cellString(forIndex index: Int) -> String {
        return cellString(forAttribute: dataArray[index]!.attributeIdentifier)
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
