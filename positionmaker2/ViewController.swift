//
//  ViewController.swift
//  positionmaker2
//
//  Created by Hiroki Taoka on 2015/06/10.
//  Copyright (c) 2015年 azukinohiroki. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, UIScrollViewDelegate, FigureViewDelegate {

  @IBOutlet var baseScrollView: MyScrollView!
  @IBOutlet var baseView: UIView!
  @IBOutlet var debugLabel: UILabel!
  
  private (set) var figureViews = [FigureView]()
  private (set) var playInterval = 3

  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.baseScrollView.delegate = self
    
    var figure = Figure.defaultFigure()

    for j in 0..<10 {
      for i in 0..<15 {
        var frame   = CGRectMake(CGFloat(i * 50), CGFloat(j*50 + 100), 30.0, 30.0)
        var fv      = FigureView(figure: figure, vc:self, frame: frame)
        fv.delegate = self
        
        self.baseView.addSubview(fv)
        self.figureViews.append(fv)
      }
    }
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    
    self.debugLabel.text = NSString(format: "w:%d h:%d", Int(self.view.frame.width), Int(self.view.frame.height)) as String
  }
  
  @IBAction func btnTapped(sender: UIButton) {
    for fv in figureViews {
      fv.startPlaying()
    }
  }
  
  // MARK: touch events
  /*
  private var _lastTouched = CGPointMake(0, 0)
  
  override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
    super.touchesBegan(touches, withEvent: event)
    
    var touch = touches.first as! UITouch
    _lastTouched = touch.locationInView(self.baseView)
  }
  
  override func touchesCancelled(touches: Set<NSObject>!, withEvent event: UIEvent!) {
    super.touchesCancelled(touches, withEvent: event)
  }
  
  override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
    super.touchesEnded(touches, withEvent: event)
  }
  
  override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
    super.touchesMoved(touches, withEvent: event)
  }
  */
  // MARK: UIScrollViewDelegate
  
  func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
    return self.baseView
  }
  
  // MARK: FigureViewDelegate
  
  func startTouch(touch: UITouch) -> UIView? {
//    _lastTouched = touch.locationInView(self.baseView)
    self.baseScrollView.canCancelContentTouches = false
    return self.baseView
  }
  
  func endTouch() {
    self.baseScrollView.canCancelContentTouches = true
  }
}