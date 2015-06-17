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
  func startTouch(touch: UITouch) -> (vc: ViewController?, parent: UIView?)
  func endTouch()
}

class FigureView: UIView {
  
  private var _figure: Figure!
  private var _parent: UIView?
  private var _vc: ViewController?
  
  var delegate: FigureViewDelegate? = nil
  
  required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  init(figure: Figure, frame: CGRect) {
    
    super.init(frame: frame)
    
    setFigure(figure)
  }
  
  init(figure :Figure) {
    
    var frame = CGRect(origin: CGPointZero, size: CGSizeMake(30, 30))
    super.init(frame: frame)
    
    setFigure(figure)
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
      (_vc, _parent) = del.startTouch(touch)
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
    
    if let vc = _vc {
      var oldOverlaps = _overlapFVs
      for fv in oldOverlaps {
        fv.requestDeleteFV(self)
      }
      
      _overlapFVs = [FigureView]()
      for fv in vc.figureViews {
        if (self == fv) { continue; }
        if CGRectContainsPoint(self.frame, fv.center) {
//        if CGRectIntersectsRect(self.frame, fv.frame) {
          _overlapFVs.append(fv)
          self.alpha = 0.5
          fv.alpha   = 0.5
        }
      }
      
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
}