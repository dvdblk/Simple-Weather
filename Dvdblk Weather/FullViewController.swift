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
        return UIColor(hue: hue, saturation: saturation - (0.17 * TEMP_CLOUDS), brightness: brightness - (0.2 * TEMP_CLOUDS), alpha: 1)
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateUI", name: "Weather", object: nil)
        UILabel.appearance().font = UIFont(name: "Helvetica", size: 17)
        todayVC = storyboard?.instantiateViewControllerWithIdentifier("Today") as! TodayViewController
        todayVC.view.frame = CGRectMake(0, 0, scrollView.frame.size.width, scrollView.frame.size.height)
        var tempFrame = todayVC.view.frame
        tempFrame.origin.x = tempFrame.width
        addChildViewController(todayVC)
        scrollView!.addSubview(todayVC.view)
        todayVC.didMoveToParentViewController(self)
        scrollView.delegate = self
        view.backgroundColor = color.HSBcolor()
        
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull2Refresh")
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
        downloader.getData({ [unowned self] err in
            if let error = err {
                var message: String = "No errors!"
                switch error {
                case .APIError(message):
                    message = "API: \(message)"
                case .HTTPRequestError(message):
                    message = "HTTP: \(message)"
                default:
                    message = "Couldnt connect to the interwebz!"
                }
                let alertControl = UIAlertController(title: "Error encountered :(", message: message, preferredStyle: .Alert)
                alertControl.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
                self.presentViewController(alertControl, animated: true, completion: nil)
                return
            }
            print("succesful download")
            NSNotificationCenter.defaultCenter().postNotificationName("Weather", object: nil)
            
        })
        self.refreshControl.endRefreshing()
    }
    
    func updateUI() {
        todayVC.updateUI()
        infoVC.updateUI()
        daytime.set()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        if daytime == .Night {
            view.tintColor = UIColor.whiteColor()
            color.setColors([205/360,1,0.1])
            infoVC.bgColor.setColors([0,0,0.78,0.2])
            return .LightContent
        }
        view.tintColor = UIColor.blackColor()
        color = MyColor()
        infoVC.bgColor.setColors([0,0,0.90,0.4])
        return .Default
    }
    
    func setBackgroundColor() {
        let cloudiness = CGFloat((WeatherData.sharedInstance.today.cell(forAttribute: "clouds")?.doubleValue)!/100)
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

