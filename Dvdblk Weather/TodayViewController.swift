//
//  TodayViewController.swift
//  Dvdblk Weather
//
//  Created by David on 06/02/2016.
//  Copyright © 2016 Revion. All rights reserved.
//

import UIKit

class TodayViewController: UIViewController {
    
    @IBOutlet weak var weatherImage: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    //let scrollView = UIScrollView(frame: UIScreen.mainScreen().bounds)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        /*self.view.addSubview(scrollView)
        self.scrollView.alpha = 0
        self.scrollView.delegate = self
        self.scrollView.contentSize = CGSize(width: 1000, height: 500)
        self.scrollView.scrollEnabled = true*/
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
