//
//  RefreshAnimator.swift
//  Dvdblk Weather
//
//  Created by David on 18/02/2016.
//  Copyright © 2016 Revion. All rights reserved.
//

import Foundation
import QuartzCore
import UIKit

class RefreshAnimator: UIView, PullToRefreshViewDelegate {
    
    var cloudImage: UIImageView!
    var pointerImage: UIImageView!
    private var defaultTransform: CGAffineTransform!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let imageSize = (frame.size.height/1.5) * 0.9
        cloudImage = UIImageView(image: UIImage(named: "refreshcloud"))
        cloudImage.frame = CGRectMake(0,0,imageSize,imageSize)
        cloudImage.contentMode = UIViewContentMode.ScaleAspectFit
        cloudImage.image = cloudImage.image!.imageWithRenderingMode(.AlwaysTemplate)
        pointerImage = UIImageView(image: UIImage(named: "pullpointer"))
        pointerImage.frame = CGRectMake(0,0,imageSize*0.5, imageSize*0.5)
        pointerImage.contentMode = UIViewContentMode.ScaleAspectFit
        pointerImage.image = pointerImage.image!.imageWithRenderingMode(.AlwaysTemplate)
        defaultTransform = pointerImage.transform
        
        self.addSubview(cloudImage)
        self.addSubview(pointerImage)
        
        let myMidY = self.frame.midY + 15
        cloudImage.frame.origin.x = self.frame.midX - cloudImage.frame.size.width/2
        cloudImage.frame.origin.y = myMidY - cloudImage.frame.size.height/2
        
        pointerImage.frame.origin = CGPoint(x: self.frame.midX - pointerImage.frame.size.width/2, y: myMidY-5)
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func pullToRefreshAnimationDidStart(view: PullToRefreshView) {
        func rotate() {
            UIView.animateWithDuration(0.5, delay: 0, options: .CurveLinear, animations: {
                self.pointerImage.transform = CGAffineTransformRotate(self.pointerImage.transform, CGFloat(M_PI_2))
                }, completion: { finish in
                    if view.loading {
                        rotate()
                    }
            })
        }
        rotate()
    }
    
    func pullToRefreshAnimationDidEnd(view: PullToRefreshView) {
        pointerImage.layer.removeAllAnimations()
        pointerImage.image = UIImage(named: "pullpointer")
        pointerImage.transform = defaultTransform
    }
    
    func pullToRefresh(view: PullToRefreshView, stateDidChange state: PullToRefreshViewState) {
        
        let degrees = (180.0 * CGFloat(M_PI)) / 180
        let moveDownArrow = {
            UIView.animateWithDuration(0.2, delay: 0.0, options: [.Repeat, .Autoreverse, .CurveEaseOut], animations: {
                self.pointerImage.transform = CGAffineTransformTranslate(self.pointerImage.transform, 0, 4)
                }, completion: nil)
        }
        
        if state != view.pullState {
            switch state {
            case .Loading:
                pointerImage.image = UIImage(named: "refreshpointer")
            case .PullToRefresh:
                if view.pullState == .ReleaseToRefresh {
                    UIView.animateWithDuration(0.2, animations: {
                        self.pointerImage.transform = CGAffineTransformRotate(self.pointerImage.transform, degrees)
                        }, completion:  { finish in
                            moveDownArrow()
                    })
                } else {
                    moveDownArrow()
                }
            case .ReleaseToRefresh:
                UIView.animateWithDuration(0.2, animations: {
                    self.pointerImage.transform = CGAffineTransformMakeRotation(degrees)
                })
            case .Default:
                return
            }
            pointerImage.image = pointerImage.image!.imageWithRenderingMode(.AlwaysTemplate)
        }
        view.pullState = state
        
    }
    
    func pullToRefresh(view: PullToRefreshView, progressDidChange progress: CGFloat) {
        
    }
}
