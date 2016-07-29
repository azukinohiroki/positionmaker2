//
//  ParentView.swift
//  positionmaker2
//
//  Created by Hiroki Taoka on 2015/06/23.
//  Copyright (c) 2015年 azukinohiroki. All rights reserved.
//

import Foundation
import UIKit

protocol ParentViewDelegate : class {
  func drawRectStarted()
  func drawRectEnded(doubleTapped: Bool)
}

class ParentView : UIView {
  
  private var _drawingRect = CGRectZero
  
  weak var dashDrawingView: DashDrawingView?
  weak var delegate: ParentViewDelegate?

  private var _dTapped = false
  private var _dTapStartP: CGPoint = CGPointZero
  private var _lastTouch: UITouch?
  
  
  override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
//    super.touchesBegan(touches, withEvent: event)
    
    let touch = touches.first as UITouch!
    let p = touch.locationInView(dashDrawingView)
    
    _dTapped = false
    
    if let lastTouch = _lastTouch {
      let diff = touch.timestamp - lastTouch.timestamp
      _dTapped = diff < 0.5
      if _dTapped {
        _dTapStartP = p
        delegate?.drawRectStarted()
      }
    }
    
    _lastTouch = touch
  }
  
  
  override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
//    super.touchesMoved(touches, withEvent: event)

    if _dTapped {
      let p = (touches.first! ).locationInView(dashDrawingView)
      let r = CGRectMake(_dTapStartP.x, _dTapStartP.y, p.x-_dTapStartP.x, p.y-_dTapStartP.y)
      dashDrawingView?.setDrawingRect(r)
    }
  }
  
  
  override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
//    super.touchesCancelled(touches, withEvent: event)
    
    touchEnd()
  }
  
  
  override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
//    super.touchesEnded(touches, withEvent: event)
    
    touchEnd()
  }
  
  
  private func touchEnd() {
    delegate?.drawRectEnded(_dTapped)
    if _dTapped {
      _dTapped = false
      dashDrawingView?.clear()
      _lastTouch = nil
    }
  }
  
  private var _draw = false
  private var _numVerticalLines   = 0
  private var _numHorizontalLines = 0
  var xInterval: CGFloat = 0
  
  
  override func drawRect(rect: CGRect) {
    if !_draw {
      return
    }
    
    var x: CGFloat =  0
    let y: CGFloat = 20
    
    for _ in 0 ..< _numVerticalLines {
      x += xInterval
      let bezier = UIBezierPath()
      bezier.moveToPoint(CGPointMake(x, y))
      bezier.addLineToPoint(CGPointMake(x, self.frame.height-y))
      UIColor.grayColor().setStroke()
      bezier.lineWidth = 2
      bezier.stroke()
    }
  }
  
  
  func setNumberOfVerticalLines(num: Int) {
    
    setNeedsDisplay()
    
    if num <= 0 {
      _numVerticalLines = 0
      if _numHorizontalLines == 0 {
        _draw = false
      }
      return
    }
    
    _draw = true
    _numVerticalLines = num;
    xInterval = self.frame.width / CGFloat(_numVerticalLines + 1)
    
    PositionController.instance().setNumberOfVerticalLines(_numVerticalLines, interval: xInterval)
  }
}