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
    
}


class FullViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var backgroundImage: UIImageView!
    
    var todayVC: TodayViewController!
    var infoVC: InfoViewController!
    var refreshControl: UIRefreshControl!
    var refreshView: UIView!
    var refreshCloud: UIImageView!
    var refreshSpinner: UIImageView!
    
    var daytime = DayCycle() {
        didSet {
            if oldValue != daytime {
                setNeedsStatusBarAppearanceUpdate()
            }
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
        
        UILabel.appearance().font = UIFont(name: "CaviarDreams", size: 17)

        view.backgroundColor = color.HSBcolor()
        view.layer.insertSublayer(gradientLayer, atIndex: 0)
        gradientLayer.frame = view.bounds
        
        todayVC = storyboard?.instantiateViewControllerWithIdentifier("Today") as! TodayViewController
        todayVC.view.frame = CGRectMake(0, 0, scrollView.frame.size.width, scrollView.frame.size.height)
        var tempFrame = todayVC.view.frame
        tempFrame.origin.x = tempFrame.width
        addChildViewController(todayVC)
        scrollView.addSubview(todayVC.view)
        todayVC.didMoveToParentViewController(self)
        todayVC.view.alpha = 0
        infoVC.view.alpha = 0
        
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
    
    override func viewDidAppear(animated: Bool) {
        delay(0.5) {
            self.scrollView.startPullToRefresh()
        }
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
                //self.refreshControl.endRefreshing()
                self.scrollView.stopPullToRefresh()
                return
            }
            print("succesful download")
            NSNotificationCenter.defaultCenter().postNotificationName("Weather", object: nil)
            //self.refreshControl.endRefreshing()
            self.scrollView.stopPullToRefresh()

        })
    }
    
    func updateUI() {
        self.todayVC.view.alpha = 0
        self.infoVC.view.alpha = 0
        self.scrollView.pullToRefreshView?.alpha = 0
        todayVC.updateUI()
        infoVC.updateUI()
        UIView.animateWithDuration(0.5 , animations: {
            self.daytime.set()
            }, completion: { finish in
            UIView.animateWithDuration(1, animations: {
                self.todayVC.view.alpha = 1
                self.infoVC.view.alpha = 1
                }, completion: { finish in
                    self.scrollView.pullToRefreshView?.alpha = 1
            })
        })
        
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        let result: UIStatusBarStyle!
        var color1: CGColorRef!
        let color2 = UIColor.clearColor().CGColor
        if daytime == .Night {
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
        gradientLayer.colors = [color1, color2]
        return result
    }
    
    func setBackgroundColor() {
        let cloudiness = CGFloat((WeatherData.sharedInstance.today.cell(forAttribute: "cloudiness")?.dblValue)!) / 100
        if daytime == .Day {
            self.view.backgroundColor = color.dayClouds(cloudiness)
        } else {
            self.view.backgroundColor = color.HSBcolor()
        }
    }
    
    var iconsOverlap = false
    var refreshAnimating = false
    
    func prepareRefresh() {
        refreshControl = UIRefreshControl()
        refreshControl.bounds.size.height = 40
        refreshControl.addTarget(self, action: "refresh", forControlEvents: .ValueChanged)
        refreshView = UIView(frame: refreshControl.bounds)
        refreshView.backgroundColor = UIColor.clearColor()
        refreshCloud = UIImageView(image: UIImage(named: "refresh1"))
        refreshSpinner = UIImageView(image: UIImage(named: "refresh2"))
        
        refreshView.addSubview(refreshCloud)
        refreshView.addSubview(refreshSpinner)
        refreshView.clipsToBounds = true
        refreshControl.tintColor = UIColor.clearColor()
        refreshControl.addSubview(refreshView)
        iconsOverlap = false
        refreshAnimating = false
    }

    
    

}

extension FullViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if (scrollView.contentOffset.y > 0) {
            scrollView.contentOffset = CGPointMake(0, 0)
        }
        
        /*var refresherSize = refreshControl.bounds
        var pullDistance = max(0.0, -self.refreshControl.frame.origin.y)
        var midX = scrollView.frame.size.width / 2.0
        var refreshCloudW = refreshCloud.bounds.size.width
        var refreshCloudH = refreshCloud.bounds.size.height
        var refreshSpinnerW = refreshSpinner.bounds.size.width
        var refreshSpinnerH = refreshSpinner.bounds.size.height
        
        var pullRate = min(max(pullDistance, 0.0), 100.0) / 100.0
        
        var cloudY = pullDistance/2.0 - refreshCloudH/2.0
        var spinnerY = pullDistance/2.0 - refreshSpinnerH/2.0
        
        var cloudX = (midX + refreshCloudW/2.0) - (refreshCloudW * pullRate)
        var spinnerX = (midX - refreshSpinnerW/2.0) + (refreshSpinnerW * pullRate)
        if (fabs(Float(cloudX-spinnerX)) < 1.0) {
            iconsOverlap = true
        }
        
        if (iconsOverlap || refreshControl.refreshing) {
            cloudX = midX - refreshCloudW/2.0
            spinnerX = midX - refreshSpinnerW/2.0
        }
        
        var cloudFrame = refreshCloud.frame
        cloudFrame.origin.x = cloudX
        cloudFrame.origin.y = cloudY
        
        var spinnerFrame = refreshSpinner.frame
        spinnerFrame.origin.x = spinnerX
        spinnerFrame.origin.y = spinnerY
        
        refreshCloud.frame =  cloudFrame
        refreshSpinner.frame = spinnerFrame
        
        refresherSize.size.height = pullDistance
        refreshView.frame = refresherSize
        
        if (refreshControl.refreshing && refreshAnimating) {
            animateRefreshView()
        }*/
    }
    
    func animateRefreshView() {
        refreshAnimating = true
        UIView.animateWithDuration(0.3, delay: 0, options: .CurveLinear, animations: {
                self.refreshSpinner.transform = CGAffineTransformRotate(self.refreshSpinner.transform, CGFloat(M_PI_2))
            
            }, completion: { finish in
                if (self.refreshControl.refreshing) {
                    self.animateRefreshView()
                } else {
                    self.resetAnimation()
                }
                
        })
    }
    
    func resetAnimation() {
        refreshAnimating = false
        iconsOverlap = false
    }
}

extension UILabel {
    override public func tintColorDidChange() {
        textColor = tintColor
    }
}

