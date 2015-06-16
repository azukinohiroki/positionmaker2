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
  func startTouch(touch: UITouch) -> UIView
  func endTouch()
}

class FigureView: UIView {
  
  private var _figure: Figure?
  private var _parent: UIView? = nil
  
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
  
  func endTouch() {
    if let del = delegate {
      del.endTouch()
    }
  }
}