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
    var refreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        todayVC = storyboard?.instantiateViewControllerWithIdentifier("Today") as! TodayViewController
        todayVC.view.frame = CGRectMake(0, 0, scrollView.frame.size.width, scrollView.frame.size.height)
        var tempFrame = todayVC.view.frame
        tempFrame.origin.x = tempFrame.width
        addChildViewController(todayVC)
        scrollView!.addSubview(todayVC.view)
        todayVC.didMoveToParentViewController(self)
        //scrollView.decelerationRate = 0.1
        scrollView.delegate = self
        
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull2Refresh")
        refreshControl.addTarget(self, action: "refresh", forControlEvents: .ValueChanged)
        scrollView.addSubview(self.refreshControl)
        refresh()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    
    func refresh() {
        /*do {
            try downloader.getData()
        } catch Downloader.Error.APIError(let errorMessage) {
            print(errorMessage)
        } catch Downloader.Error.HTTPRequestError {
            print("HTTP Request Error")
        } catch {
            print("Some error")
        }*/
        downloader.getData({ err in
            if let error = err {
                switch error {
                case .APIError(let message):
                    print(message)
                case .HTTPRequestError:
                    print("http")
                }
            }
            print("downloaded")
        })
        self.refreshControl.endRefreshing()
    }
}

extension FullViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
    }
}

