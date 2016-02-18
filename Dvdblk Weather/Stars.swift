//
//  Stars.swift
//  Dvdblk Weather
//
//  Created by David on 17/02/2016.
//  Copyright © 2016 Revion. All rights reserved.
//

import UIKit

class Stars: UIView {

    private var cloudiness: Double!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clearColor()
        self.alpha = 0
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(frame: CGRect, cloudiness: Double) {
        self.init(frame: frame)
        self.cloudiness = cloudiness
    }
    
    override func drawRect(rect: CGRect) {
        
        func rand(max: Int = 3) -> Int {
            return Int(arc4random_uniform(UInt32(max)) + 1)
        }
        
        var coordArray = [(x:CGFloat, y:CGFloat, used: Bool)]()
        let tempW = Int(self.frame.width)
        let tempH = Int(self.frame.height/3)
    
        for x in 1..<tempW {
            for y in 15..<tempH+rand(25) {
                coordArray.append((CGFloat(x), CGFloat(y), false))
            }
        }        
        
        for _ in 0..<150+rand(10) {
            var element = coordArray[rand(coordArray.count)-1]
            if element.used == true {
                continue
            }
            element.used = true
            let point = CGPoint(x: element.x, y: element.y)
            let radius: CGFloat = CGFloat(rand(6)) * 0.2 + 0.4
            let alpha: CGFloat = CGFloat(rand(25)) / 100.0 + 0.70 - (point.y/CGFloat(tempH))/1.5
            let circle = UIBezierPath(ovalInRect: CGRect(origin: point, size: CGSize(width: radius, height: radius)))
            UIColor(red: 255, green: 255, blue: 255, alpha: alpha).setFill()
            circle.fill()
        }
        
        
    }


}
