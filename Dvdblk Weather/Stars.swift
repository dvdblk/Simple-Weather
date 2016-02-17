//
//  Stars.swift
//  Dvdblk Weather
//
//  Created by David on 17/02/2016.
//  Copyright © 2016 Revion. All rights reserved.
//

import UIKit

class Stars: UIView {

    var cloudiness: Double!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clearColor()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(frame: CGRect, cloudiness: Double) {
        self.init(frame: frame)
        self.cloudiness = cloudiness
        //self.alpha = 0 for later anim
    }
    
    
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        
        func rand(max: UInt32 = 3) -> Int {
            return Int(arc4random_uniform(max) + 1)
        }
        
        /*var coordArray: [(x, y, radius, alpha)] = []
        let xCount = 60 + rand(20) - rand(20)
        let yCount = 10 + rand(5) - rand(5)
        let xDiff = self.frame.size.width / xCount
        for x in xCount {
            var tempX =  rand(
            coordArray.append((rand(x+)
        }*/
        
        
        var coordArray: [(x, y, used)] = []
        let tempW = Int(self.frame.width)
        let tempH = Int(self.frame.height/3.5)
    
        for x in 1..<tempW {
            for y in 20..<tempH {
                coordArray[x][y] = (x, y, false)
            }
        }
        
        let point = CGPoint(x: 80, y: 80)
        let circle = UIBezierPath(ovalInRect: CGRect(origin: point, size: CGSize(width: 50.0, height: 50.0)))
        UIColor.whiteColor().setFill()
        circle.fill()
    }


}
