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
    
    let downloader = Downloader()
    var todayVC: TodayViewController!
    var infoVC: InfoViewController!
    var refreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        todayVC = storyboard?.instantiateViewControllerWithIdentifier("Today") as! TodayViewController
        infoVC = storyboard?.instantiateViewControllerWithIdentifier("Info") as! InfoViewController
        todayVC.view.frame = CGRectMake(0, 0, scrollView.frame.size.width, scrollView.frame.size.height)
        var tempFrame = todayVC.view.frame
        tempFrame.origin.x = tempFrame.width
        addChildViewController(todayVC)
        addChildViewController(infoVC)
        scrollView!.addSubview(todayVC.view)
        todayVC.didMoveToParentViewController(self)
        scrollView.delegate = self
        
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull2Refresh")
        refreshControl.addTarget(self, action: "refresh", forControlEvents: .ValueChanged)
        scrollView.addSubview(self.refreshControl)
        refresh()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateUI", name: "Weather", object: nil)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    
    func refresh() {
        downloader.getData({ err in
            if let error = err {
                switch error {
                case .APIError(let message):
                    print("API ERR: \(message)")
                    return
                case .HTTPRequestError(let message):
                    print("HTTP ERR: \(message)")
                    return
                }
            }
            print("succesful download")
            NSNotificationCenter.defaultCenter().postNotificationName("Weather", object: nil)
        })
        self.refreshControl.endRefreshing()
    }
    
    func updateUI() {
        todayVC.updateUI()
        infoVC.updateUI()
    }
}

extension FullViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
    }
}

