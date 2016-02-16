//
//  FullViewController.swift
//  Dvdblk Weather
//
//  Created by David on 05/02/2016.
//  Copyright © 2016 Revion. All rights reserved.
//

import UIKit

struct MyColor {
    var hue: CGFloat
    var saturation: CGFloat
    var brightness: CGFloat
    var alpha: CGFloat
    
    init() {
        self.hue = 210/360
        self.saturation = 0.47
        self.brightness = 0.90
        self.alpha = 1
    }
    
    mutating func setColors(arr: [CGFloat]) {
        self.hue = arr[0]
        self.saturation = arr[1]
        self.brightness = arr[2]
        self.alpha = arr[3]
    }
    
    func HSBcolor(arr: [CGFloat]) -> UIColor {
        return UIColor(hue: arr[0], saturation: arr[1], brightness: arr[2], alpha: arr[3])
    }
    
    func HSBcolor() -> UIColor {
        return HSBcolor([hue, saturation, brightness, alpha])
    }
    
    func dayClouds(cloudiness: CGFloat) -> UIColor {
        return UIColor(hue: hue, saturation: saturation - (0.17 * cloudiness), brightness: brightness - (0.2 * cloudiness), alpha: 1)
    }
    
    func nightClouds(cloudiness: CGFloat) -> UIColor {
        return HSBcolor()
    }
    
}


class FullViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var backgroundImage: UIImageView!
    var daytime = DayCycle() {
        didSet {
            if oldValue != daytime {
                setNeedsStatusBarAppearanceUpdate()
            }
            setBackgroundColor()
        }
    }
    let downloader = Downloader()
    var todayVC: TodayViewController!
    var infoVC: InfoViewController!
    var refreshControl: UIRefreshControl!
    var color = MyColor()
    let gradientLayer = CAGradientLayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateUI", name: "Weather", object: nil)
        UILabel.appearance().font = UIFont(name: "Helvetica", size: 17)
        view.backgroundColor = color.HSBcolor()
        view.layer.insertSublayer(gradientLayer, atIndex: 0)
        gradientLayer.frame = view.bounds

        todayVC = storyboard?.instantiateViewControllerWithIdentifier("Today") as! TodayViewController
        todayVC.view.frame = CGRectMake(0, 0, scrollView.frame.size.width, scrollView.frame.size.height)
        var tempFrame = todayVC.view.frame
        tempFrame.origin.x = tempFrame.width
        addChildViewController(todayVC)
        scrollView!.addSubview(todayVC.view)
        todayVC.didMoveToParentViewController(self)
        todayVC.view.alpha = 0
        infoVC.view.alpha = 0
        
        
        scrollView.delegate = self
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refresh", forControlEvents: .ValueChanged)
        scrollView.addSubview(self.refreshControl)
        refresh()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let tempInfoVC = segue.destinationViewController as? InfoViewController where segue.identifier == "InfoViewSegue" {
            infoVC = tempInfoVC
            infoVC.fullVC = self
        }
    }
    
    func refresh() {
        downloader.getData({ err in
            if let error = err {
                var message: String = "No errors!"
                switch error {
                case .APIError(let errorMessage):
                    message = "API: \(errorMessage)"
                case .HTTPRequestError(let errorMessage):
                    message = "HTTP: \(errorMessage)"
                }
                let alertControl = UIAlertController(title: "Error encountered!", message: message, preferredStyle: .Alert)
                alertControl.addAction(UIAlertAction(title: "Dismiss", style: .Default, handler: nil))
                self.presentViewController(alertControl, animated: true, completion: nil)
                alertControl.view.tintColor = UIColor.blackColor()
                self.refreshControl.endRefreshing()
                return
            }
            print("succesful download")
            NSNotificationCenter.defaultCenter().postNotificationName("Weather", object: nil)
            self.refreshControl.endRefreshing()

        })
    }
    
    func updateUI() {
        todayVC.updateUI()
        infoVC.updateUI()
        UIView.animateWithDuration(0.5, animations: { self.daytime.set() }, completion: { finish in
            UIView.animateWithDuration(1.5, animations: {
                self.todayVC.view.alpha = 1
                self.infoVC.view.alpha = 1
            })
        })
        
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        let result: UIStatusBarStyle!
        var color1: CGColorRef!
        let color2 = UIColor.clearColor().CGColor
        if daytime == .Night {
            view.tintColor = UIColor.whiteColor()
            color.setColors([205/360,1,0.1,1])
            infoVC.bgColor.setColors([0,0,0.78,0.2])
            color1 = UIColor(hue: 205/360, saturation: 1, brightness: 0.17, alpha: 1).CGColor
            result = .LightContent
        } else {
            view.tintColor = UIColor.blackColor()
            color = MyColor()
            infoVC.bgColor.setColors([0,0,0.90,0.4])
            color1 = UIColor(red: 255, green: 255, blue: 255, alpha: 0.25).CGColor
            result = .Default
        }
        gradientLayer.colors = [color1, color2]
        return result
    }
    
    func setBackgroundColor() {
        let cloudiness = CGFloat((WeatherData.sharedInstance.today.cell(forAttribute: "clouds")?.dblValue)!) / 100
        if daytime == .Day {
            self.view.backgroundColor = color.dayClouds(cloudiness)
        } else {
            self.view.backgroundColor = color.nightClouds(cloudiness)
        }
    }


}

extension FullViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if (scrollView.contentOffset.y > 0) {
            scrollView.contentOffset = CGPointMake(0, 0)
        }
    }
}

extension UILabel {
    override public func tintColorDidChange() {
        textColor = tintColor
    }
}

