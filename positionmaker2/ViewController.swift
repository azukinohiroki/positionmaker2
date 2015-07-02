//
//  ViewController.swift
//  positionmaker2
//
//  Created by Hiroki Taoka on 2015/06/10.
//  Copyright (c) 2015年 azukinohiroki. All rights reserved.
//

import UIKit
import CoreData
import SCLAlertView

class ViewController: UIViewController, UIScrollViewDelegate, FigureViewDelegate, ParentViewDelegate {

  @IBOutlet var baseScrollView: MyScrollView!
  @IBOutlet var baseView: ParentView!
  @IBOutlet var debugLabel: UILabel!
  @IBOutlet var dashDrawingView: DashDrawingView!
  
  private (set) var figureViews = [FigureView]()
  private (set) var playInterval = 3

  override func viewDidLoad() {
    super.viewDidLoad()
    
    baseScrollView.delegate = self
    baseView.delegate = self
    baseView.dashDrawingView = dashDrawingView
    
    dashDrawingView.userInteractionEnabled = false
    
    var recordPlayController = RecordPlayController.instance()
    
    var figure = Figure.defaultFigure()

    for j in 0..<10 {
      for i in 0..<15 {
        var frame   = CGRectMake(CGFloat(i * 50), CGFloat(j*50 + 100), 30.0, 30.0)
        var fv      = FigureView(figure: figure, vc: self, frame: frame)
        fv.delegate = self
        
        baseView.addSubview(fv)
        figureViews.append(fv)
      }
    }
    
    recordPlayController.startRecording(figureViews)
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    
    self.debugLabel.text = NSString(format: "w:%d h:%d", Int(self.view.frame.width), Int(self.view.frame.height)) as String
  }
  
  @IBAction func recTapped(sender: UIButton) {

    RecordPlayController.instance().recordLocation(figureViews)
  }
  
  @IBAction func playTapped(sender: UIButton) {

    RecordPlayController.instance().startPlaying(figureViews)
  }
  
  @IBAction func undoTapped(sender: UIButton) {
    ActionLogController.instance().undo()
  }
  
  @IBAction func redoTapped(sender: UIButton) {
    ActionLogController.instance().redo()
  }
  
  
  func removeFVFromList(fv: FigureView) {
    figureViews = figureViews.filter() { $0 != fv }
  }
  
  func addFVToList(fv: FigureView) {
    figureViews.append(fv)
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
    return baseView
  }
  
  
  
  // MARK: FigureViewDelegate
  
  func startTouch(view: FigureView, touch: UITouch) -> UIView? {
    baseScrollView.canCancelContentTouches = false
    return baseView
  }
  
  func endTouch(view: FigureView, beganPoint: CGPoint) {
    baseScrollView.canCancelContentTouches = true
    
    var fvs = [FigureView]()
    for fv in figureViews {
      if fv.selected && fv != view {
        fvs.append(fv)
      }
    }
    
    var o = view.frame.origin
    
    var alc = ActionLogController.instance()
    if fvs.isEmpty {
      alc.addMove(from: beganPoint, to: o, fv: view)
    } else {
      alc.addMultiMove(from: beganPoint, to: o, fv: view, fvs: fvs)
    }
  }
  
  
  
  // MARK: ParentViewDelegate
  
  func drawRectStarted() {
    baseScrollView.canCancelContentTouches = false
  }
  
  func drawRectEnded(doubleTapped: Bool) {
    baseScrollView.canCancelContentTouches = true
    
    if doubleTapped {
      var rect = dashDrawingView.getDrawingRect()
      
      var scale = baseScrollView.zoomScale
      var offset = baseScrollView.contentOffset
      var frame = baseView.frame
      
      for fv in figureViews {
        var p = CGPointMake(fv.center.x*scale-offset.x, fv.center.y*scale-offset.y)
        fv.selected = CGRectContainsPoint(rect, p)
      }
      
    } else {
      for fv in figureViews {
        if fv.selected {
          fv.selected = false
        }
      }
    }
  }
}