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
    var intValue: UnixTime?
    var doubleValue: Double?

    init?(intValue: UnixTime?, attributeID: String) {
        self.intValue = intValue
        self.attributeIdentifier = attributeID
    }
    
    init?(dblValue: Double?, attributeID: String) {
        self.doubleValue = dblValue
        self.attributeIdentifier = attributeID
    }
}

class OneDayWeatherExtended: OneDayWeather {
    var dataArray: [dataCell?] = []
    
    func cell(forAttribute attr: String) -> String {
        for data in dataArray {
            if data?.attributeIdentifier == attr {
                let result = data?.intValue
                if result == nil { return String(data!.doubleValue!) }
                return result!.toHour
            }
        }
        return "---"
    }
    
    func cell(forIndex index: Int) -> String {
        return cell(forAttribute: dataArray[index]!.attributeIdentifier)
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
