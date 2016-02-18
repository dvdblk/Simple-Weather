//
//  InfoViewController.swift
//  Dvdblk Weather
//
//  Created by David on 06/02/2016.
//  Copyright © 2016 Revion. All rights reserved.
//

import UIKit

class InfoViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    var currentVC: CurrentViewController!
    var forecast5VC: Forecast5ViewController!
    var fullVC: FullViewController!
    var bgColor = MyColor() {
        didSet {
            setBackgroundColor()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.setNeedsLayout()
        let scrollH = scrollView.frame.size.height
        scrollView.layoutIfNeeded()
        let scrollW = 2 * scrollView.bounds.size.width
        currentVC = storyboard?.instantiateViewControllerWithIdentifier("Current") as! CurrentViewController
        forecast5VC = storyboard?.instantiateViewControllerWithIdentifier("Forecast5") as! Forecast5ViewController
        currentVC.view.frame = CGRectMake(0, 0, scrollView.frame.size.width, scrollView.frame.size.height)
        var tempFrame = currentVC.view.frame
        tempFrame.origin.x = tempFrame.width
        forecast5VC.view.frame = tempFrame
        
        addChildViewController(forecast5VC)
        scrollView!.addSubview(forecast5VC.view)
        forecast5VC.didMoveToParentViewController(self)
        addChildViewController(currentVC)
        scrollView.addSubview(currentVC.view)
        currentVC.didMoveToParentViewController(self)
    
        scrollView.contentSize = CGSizeMake(scrollW, scrollH)
        scrollView.layer.cornerRadius = 10
        scrollView.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    
    func updateUI() {
        currentVC.tableView.reloadData()
        forecast5VC.tableView.reloadData()
        setBackgroundColor()
    }
    
    func setBackgroundColor() {
        scrollView.backgroundColor = bgColor.HSBcolor()
        pageControl.pageIndicatorTintColor = bgColor.HSBcolor()
        pageControl.currentPageIndicatorTintColor = view.tintColor

    }

}

extension InfoViewController: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        pageControl.currentPage = Int(scrollView.contentOffset.x / scrollView.frame.size.width)
    }
}
