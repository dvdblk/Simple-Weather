//
// Animator.swift
//
// Copyright (c) 2014 Josip Cavar
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import Foundation
import QuartzCore
import UIKit

/*internal class AnimatorView: UIView {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let activityIndicatorView: UIActivityIndicatorView = {
        let activity = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        activity.translatesAutoresizingMaskIntoConstraints = false
        return activity
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.borderWidth = 5
        autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
        addSubview(titleLabel)
        addSubview(activityIndicatorView)
        
        let leftActivityConstraint = NSLayoutConstraint(item: activityIndicatorView, attribute: .Left, relatedBy: .Equal, toItem: self, attribute: .Left, multiplier: 1, constant: 16)
        let centerActivityConstraint = NSLayoutConstraint(item: activityIndicatorView, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant: 0)
        
        let leftTitleConstraint = NSLayoutConstraint(item: titleLabel, attribute: .Left, relatedBy: .Equal, toItem: activityIndicatorView, attribute: .Right, multiplier: 1, constant: 16)
        let centerTitleConstraint = NSLayoutConstraint(item: self, attribute: .CenterY, relatedBy: .Equal, toItem: titleLabel, attribute: .CenterY, multiplier: 1, constant: 0)

        addConstraints([leftActivityConstraint, centerActivityConstraint, leftTitleConstraint, centerTitleConstraint])
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class Animator: PullToRefreshViewDelegate {
    
    internal let animatorView: AnimatorView

    init(frame: CGRect) {
        animatorView = AnimatorView(frame: frame)
    }
    
    func pullToRefreshAnimationDidStart(view: PullToRefreshView) {
        animatorView.activityIndicatorView.startAnimating()
        animatorView.titleLabel.text = "Loading"
    }
    
    func pullToRefreshAnimationDidEnd(view: PullToRefreshView) {
        animatorView.activityIndicatorView.stopAnimating()
        animatorView.titleLabel.text = ""
    }
    
    func pullToRefresh(view: PullToRefreshView, progressDidChange progress: CGFloat) {
        
    }
    
    func pullToRefresh(view: PullToRefreshView, stateDidChange state: PullToRefreshViewState) {
        switch state {
        case .Loading:
            animatorView.titleLabel.text = "Loading"
        case .PullToRefresh:
            animatorView.titleLabel.text = "Pull to refresh"
        case .ReleaseToRefresh:
            animatorView.titleLabel.text = "Release to refresh"
        }
    }
}*/


class RefreshAnimator: UIView, PullToRefreshViewDelegate {
    
    var cloudImage: UIImageView!
    var pointerImage: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let imageSize = frame.size.height/1.5
        cloudImage = UIImageView(image: UIImage(named: "refreshcloud"))
        cloudImage.frame = CGRectMake(0,0,imageSize,imageSize)
        cloudImage.contentMode = UIViewContentMode.ScaleAspectFit
        cloudImage.image = cloudImage.image!.imageWithRenderingMode(.AlwaysTemplate)
        pointerImage = UIImageView(image: UIImage(named: "pullpointer"))
        pointerImage.frame = CGRectMake(0,0,imageSize*0.5, imageSize*0.5)
        pointerImage.contentMode = UIViewContentMode.ScaleAspectFit
        pointerImage.image = pointerImage.image!.imageWithRenderingMode(.AlwaysTemplate)

        //pointerImage.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(cloudImage)
        self.addSubview(pointerImage)
        cloudImage.frame.origin.x = self.frame.midX - cloudImage.frame.size.width/2
        cloudImage.frame.origin.y = self.frame.midY - cloudImage.frame.size.height/2
        
        pointerImage.frame.origin = CGPoint(x: self.frame.midX - pointerImage.frame.size.width/2, y: self.frame.midY-5)
        
        //let centerCloudImageConstraintX = NSLayoutConstraint(item: cloudImage, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1, constant: 0)
        
        //let centerCloudImageConstraintY = NSLayoutConstraint(item: self, attribute: .CenterY, relatedBy: .Equal, toItem: cloudImage, attribute: .CenterY, multiplier: 1, constant: 0)
        
        
        /*let centerPointerImageConstraintX = NSLayoutConstraint(item: self, attribute: .CenterX, relatedBy: .Equal, toItem: pointerImage, attribute: .CenterX, multiplier: 1, constant: 0)
        
        
        let centerPointerImageConstraintY = NSLayoutConstraint(item: self, attribute: .CenterY, relatedBy: .Equal, toItem: pointerImage, attribute: .CenterY, multiplier: 1, constant: 0)*/
        
        //addConstraints([center])
        //addConstraints([centerCloudImageConstraintX])
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func pullToRefreshAnimationDidStart(view: PullToRefreshView) {
        
    }
    
    func pullToRefreshAnimationDidEnd(view: PullToRefreshView) {
        
    }
    
    func pullToRefresh(view: PullToRefreshView, stateDidChange state: PullToRefreshViewState) {
        switch state {
        case .Loading:
            pointerImage.image = UIImage(named: "refreshpointer")
        case .PullToRefresh:
            pointerImage.image = UIImage(named: "pullpointer")
        case .ReleaseToRefresh:
            pointerImage.image = UIImage(named: "releasepointer")
        }
        pointerImage.image = pointerImage.image!.imageWithRenderingMode(.AlwaysTemplate)

    }
    
    func pullToRefresh(view: PullToRefreshView, progressDidChange progress: CGFloat) {
        
    }
}
