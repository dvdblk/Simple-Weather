//
//  FullViewController.swift
//  Dvdblk Weather
//
//  Created by David on 05/02/2016.
//  Copyright © 2016 Revion. All rights reserved.
//

import UIKit

class FullViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var backgroundImage: UIImageView!
    
    var todayVC: TodayViewController!
    var infoVC: InfoViewController!
    var refreshControl: UIRefreshControl!
    var refreshView: UIView!
    var refreshCloud: UIImageView!
    var refreshSpinner: UIImageView!
    
    var weather = WeatherData()
    var daytime = DayCycle() {
        didSet {
            if oldValue != daytime {
                // change whole UI tint colors and stuff only when the cycle changes
                setNeedsStatusBarAppearanceUpdate()
            }
            // set color everytime due to cloudiness changing
            setBackgroundColor()
        }
    }
    let downloader = Downloader()
    var color = MyColor()
    var bgrnd: Stars?
    let gradientLayer = CAGradientLayer()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.fullVC = self
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateUI", name: "Weather", object: nil)
        
        view.backgroundColor = color.HSBcolor()
        view.layer.insertSublayer(gradientLayer, atIndex: 0)
        gradientLayer.frame = view.bounds
        
        todayVC = storyboard?.instantiateViewControllerWithIdentifier("Today") as! TodayViewController
        todayVC.weather = weather
        todayVC.view.frame = CGRectMake(0, 0, scrollView.frame.size.width, scrollView.frame.size.height)
        var tempFrame = todayVC.view.frame
        tempFrame.origin.x = tempFrame.width
        addChildViewController(todayVC)
        scrollView.addSubview(todayVC.view)
        todayVC.didMoveToParentViewController(self)
        todayVC.view.alpha = 0

        scrollView.layoutIfNeeded()
        let refreshAnimator = RefreshAnimator(frame: CGRectMake(0, 0, scrollView.bounds.size.width, 80))
        scrollView.addPullToRefreshWithAction({
            NSOperationQueue().addOperationWithBlock({
                self.refresh()
            })
            }, withAnimator: refreshAnimator)
        scrollView.delegate = self
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    
    // refresh on app startup
    override func viewDidAppear(animated: Bool) {
        delay(0.5) {
            self.scrollView.startPullToRefresh()
        }
    }
    
    // set info view controllers parent + weather
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let tempInfoVC = segue.destinationViewController as? InfoViewController where segue.identifier == "InfoViewSegue" {
            infoVC = tempInfoVC
            infoVC.weather = weather
            infoVC.fullVC = self
            infoVC.view.alpha = 0
        }
    }
    
    func refresh() {
        downloader.getData(weather) { err in
            if let error = err {
                var message: String = "Please pull to refresh! "
                switch error {
                case .APIError(let errorMessage):
                    message += "API: \(errorMessage)"
                case .HTTPRequestError(let errorMessage):
                    message += "HTTP: \(errorMessage)"
                }
                let alertControl = UIAlertController(title: "Error encountered!", message: message, preferredStyle: .Alert)
                alertControl.addAction(UIAlertAction(title: "Dismiss", style: .Default, handler: nil))
                self.scrollView.stopPullToRefresh()
                self.presentViewController(alertControl, animated: true, completion: nil)
                alertControl.view.tintColor = UIColor.blackColor()
                return
            }
            //successful download -> send notification to change data / UI, stop refresh loading
            NSNotificationCenter.defaultCenter().postNotificationName("Weather", object: nil)
            self.scrollView.stopPullToRefresh()
        }
    }
    
    // notification handler
    func updateUI() {
        self.todayVC.view.alpha = 0
        self.infoVC.view.alpha = 0
        self.scrollView.pullToRefreshView?.alpha = 0
        todayVC.updateData()
        infoVC.updateData()
        UIView.animateWithDuration(0.5, animations: {
            self.daytime.set(self.weather)
            }, completion: { finish in
            UIView.animateWithDuration(0.6, animations: {
                self.todayVC.view.alpha = 1
                self.infoVC.view.alpha = 1
                }, completion: { finish in
                    self.scrollView.pullToRefreshView?.alpha = 1
            })
        })
        
    }
    
    // change UI based on day / night, called only on change
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        let result: UIStatusBarStyle!
        var color1: CGColorRef!
        let color2 = UIColor.clearColor().CGColor
        if daytime == .Night {
            bgrnd?.removeFromSuperview()
            bgrnd = Stars(frame: CGRectMake(0,0,view.frame.size.width, view.frame.size.height))
            view.insertSubview(bgrnd!, belowSubview: scrollView)
            self.bgrnd!.alpha = 1
            view.tintColor = UIColor.whiteColor()
            color.setColors([205/360,1,0.1,1])
            infoVC.bgColor.setColors([0,0,0.78,0.2])
            color1 = UIColor(hue: 205/360, saturation: 1, brightness: 0.17, alpha: 1).CGColor
            result = .LightContent
        } else {
            bgrnd?.removeFromSuperview()
            view.tintColor = UIColor.blackColor()
            color = MyColor()
            infoVC.bgColor.setColors([0,0,0.90,0.4])
            color1 = UIColor(red: 255, green: 255, blue: 255, alpha: 0.25).CGColor
            result = .Default
        }
        infoVC.setBackgroundColor()
        gradientLayer.colors = [color1, color2]
        return result
    }
    
    // set background color, called every refresh (due to cloudiness factor)
    func setBackgroundColor() {
        let cloudiness = CGFloat((weather.today.cell(forAttribute: "cloudiness")?.dblValue)!) / 100
        if daytime == .Day {
            self.view.backgroundColor = color.dayClouds(cloudiness)
        } else {
            self.view.backgroundColor = color.HSBcolor()
        }
    }
}

extension FullViewController: UIScrollViewDelegate {
    // block scrolling up
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

