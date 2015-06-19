//
//  FigureView.swift
//  positionmaker2
//
//  Created by Hiroki Taoka on 2015/06/11.
//  Copyright (c) 2015年 azukinohiroki. All rights reserved.
//

import Foundation
import UIKit

protocol FigureViewDelegate {
  func startTouch(touch: UITouch) -> UIView?
  func endTouch()
}

class FigureView: UIView {
  
  private var _figure: Figure!
  private var _parent: UIView?
  private var _vc: ViewController!
  
  var delegate: FigureViewDelegate? = nil
  
  
  
  required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  init(figure: Figure, vc: ViewController, frame: CGRect) {
    
    super.init(frame: frame)
    
    _vc = vc
    setFigure(figure)
    _startingPoint = frame.origin
  }
  
  init(figure :Figure, vc: ViewController) {
    
    var frame = CGRect(origin: CGPointZero, size: CGSizeMake(30, 30))
    super.init(frame: frame)
    
    _vc  = vc
    setFigure(figure)
    _startingPoint = frame.origin
  }
  
  
  
  private func setFigure(figure: Figure) {
    
    _figure = figure
    
    var color = figure.color.intValue
    var red   = CGFloat((color >> 16) & 0xFF)
    var green = CGFloat((color >>  8) & 0xFF)
    var blue  = CGFloat( color        & 0xFF)
    self.backgroundColor = UIColor(red: red/255.0, green: green/255.0, blue: blue/255.0, alpha: 1.0)
  }
  
  private var _lastTouched: CGPoint = CGPointZero
  
  override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
    super.touchesBegan(touches, withEvent: event)
    
    if let del = delegate {
      var touch = touches.first as! UITouch
      _parent = del.startTouch(touch)
      _lastTouched = touch.locationInView(_parent)
    }
  }
  
  override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
    super.touchesMoved(touches, withEvent: event)
    
    if let parent = _parent {
      var touch = touches.first as! UITouch
      var point = touch.locationInView(parent)
      var dx = _lastTouched.x - point.x
      var dy = _lastTouched.y - point.y
      
      var origin = self.frame.origin
      var size   = self.frame.size
      self.frame = CGRectMake(origin.x - dx, origin.y - dy, size.width, size.height)
      
      _lastTouched = point
      
      if _recording {
        recordMotion(CGPointMake(dx, dy))
      }
    }
  }
  
  override func touchesCancelled(touches: Set<NSObject>!, withEvent event: UIEvent!) {
    super.touchesCancelled(touches, withEvent: event)
    
    endTouch()
    _parent = nil;
  }
  
  override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
    super.touchesEnded(touches, withEvent: event)
    
    endTouch()
    _parent = nil;
  }
  
  private var _overlapFVs: [FigureView] = []
  
  func endTouch() {
    
    var oldOverlaps = _overlapFVs
    for fv in oldOverlaps {
      fv.requestDeleteFV(self)
    }
    
    _overlapFVs = [FigureView]()
    for fv in _vc.figureViews {
      if (self == fv) { continue; }
      if CGRectContainsPoint(self.frame, fv.center) {
        //        if CGRectIntersectsRect(self.frame, fv.frame) {
        _overlapFVs.append(fv)
        self.alpha = 0.5
        fv.alpha   = 0.5
      }
    }
    
      if _recording {
        saveMotion()
      }
    
    if _overlapFVs.isEmpty {
      self.alpha = 1
      
    } else {
      for fv in _overlapFVs {
        fv.requestAddFV(self)
      }
      _overlapFVs.append(self)
    }
    delegate?.endTouch()
  }
  
  func requestAddFV(fv: FigureView) {
    if _overlapFVs.isEmpty {
      _overlapFVs = [self, fv]
      
    } else {
      _overlapFVs.append(fv)
    }
  }
  
  func requestDeleteFV(fv: FigureView) {
    if _overlapFVs.isEmpty {
      return
      
    } else {
      _overlapFVs = _overlapFVs.filter() { $0 != fv }
      if _overlapFVs.count == 1 {
        _overlapFVs.removeAll(keepCapacity: true)
        alpha = 1
      }
    }
  }
  
  
  
  private var _recording = true
  private var _recordedMotion: [[CGPoint]] = []
  private var _tmpRecordArray: [CGPoint] = []
  private var _startingPoint: CGPoint = CGPointZero
  
  private func recordMotion(p: CGPoint) {
    _tmpRecordArray.append(p)
  }
  
  private func saveMotion() {
    _recordedMotion.append(_tmpRecordArray)
    _tmpRecordArray = []
  }
  
  private var _playing = false
  
  func startPlaying() {
    
    _playing = true
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), { () -> Void in
      
      dispatch_async(dispatch_get_main_queue(), { () -> Void in
        var p = self._startingPoint
        var s = self.frame.size
        UIView.animateWithDuration(1, animations: { () -> Void in
          self.frame = CGRectMake(p.x, p.y, s.width, s.height)
          return
        })
      })
      sleep(1)
      
      var index = 0
      while self._playing {
        if self._recordedMotion.count <= index {
          self._playing = false
          return
        }
        
        var array = self._recordedMotion[index]
        if array.count == 0 {
          continue
        }
        
        self.playASequence(array)
        ++index
      }
    })
  }
  
  private func playASequence(array: [CGPoint]) {
//    _recording = false
    var interval = 1//_vc.playInterval
    var count = array.count
    
    if count == 0 { return }
    
    var wait = (interval * 50000) / count
    
    for p in array {
      
      dispatch_async(dispatch_get_main_queue(), { () -> Void in
        self.center = CGPointMake(self.center.x - p.x, self.center.y - p.y)
        return
      })
      
      usleep(UInt32(wait))
    }
  }
}