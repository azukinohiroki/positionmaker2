//
//  ViewController.swift
//  positionmaker2
//
//  Created by Hiroki Taoka on 2015/06/10.
//  Copyright (c) 2015年 azukinohiroki. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, UIScrollViewDelegate, FigureViewDelegate, ParentViewDelegate {

  @IBOutlet var baseScrollView: MyScrollView!
  @IBOutlet var baseView: ParentView!
  @IBOutlet var debugLabel: UILabel!
  @IBOutlet var dashDrawingView: DashDrawingView!
  
  private (set) var figureViews = [FigureView]()
  private (set) var playInterval = 3
  
  private let _actionLogController = ActionLogController()

  override func viewDidLoad() {
    super.viewDidLoad()
    
    baseScrollView.delegate = self
    baseView.delegate = self
    baseView.dashDrawingView = dashDrawingView
    
    dashDrawingView.userInteractionEnabled = false
    
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
  
  @IBAction func undoTapped(sender: UIButton) {
    var log_ = _actionLogController.undo()
    if let log = log_ {
      switch log.type {
      case .MOVE:
        var move = log as! MoveObject
        var size = move.fv.frame.size
        move.fv.frame = CGRectMake(move.from.x, move.from.y, size.width, size.height)
        
      case .MULTI_MOVE:
        var move = log as! MultiMoveObject
        var size = move.fv.frame.size
        move.fv.frame = CGRectMake(move.from.x, move.from.y, size.width, size.height)
        var dx = move.to.x - move.from.x
        var dy = move.to.y - move.from.y
        for fv in move.fvs {
          fv.center = CGPointMake(fv.center.x - dx, fv.center.y - dy)
        }
      }
    }
  }
  
  @IBAction func redoTapped(sender: UIButton) {
    var log_ = _actionLogController.redo()
    if let log = log_ {
      switch log.type {
      case .MOVE:
        var move = log as! MoveObject
        var size = move.fv.frame.size
        move.fv.frame = CGRectMake(move.to.x, move.to.y, size.width, size.height)
        
      case .MULTI_MOVE:
        var move = log as! MultiMoveObject
        var size = move.fv.frame.size
        move.fv.frame = CGRectMake(move.to.x, move.to.y, size.width, size.height)
        var dx = move.to.x - move.from.x
        var dy = move.to.y - move.from.y
        for fv in move.fvs {
          fv.center = CGPointMake(fv.center.x + dx, fv.center.y + dy)
        }
      }
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
    
    if fvs.isEmpty {
      _actionLogController.addMove(from: beganPoint, to: view.frame.origin, fv: view)
    } else {
      _actionLogController.addMultiMove(from: beganPoint, to: view.frame.origin, fv: view, fvs: fvs)
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
      
      for fv in figureViews {
        fv.selected = CGRectContainsPoint(rect, fv.center)
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