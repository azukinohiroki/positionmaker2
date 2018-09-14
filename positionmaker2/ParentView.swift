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
  
  private var _drawingRect = CGRect.zero
  
  weak var dashDrawingView: DashDrawingView?
  weak var delegate: ParentViewDelegate?

  private var _dTapped = false
  private var _dTapStartP: CGPoint = CGPoint.zero
  private var _lastTouch: UITouch?
  
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//    super.touchesBegan(touches, withEvent: event)
    
    if let touch = touches.first as UITouch? {
      let p = touch.location(in: dashDrawingView)
      
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
  }
  
  
  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
//    super.touchesMoved(touches, withEvent: event)

    if _dTapped {
      let p = (touches.first! ).location(in: dashDrawingView)
      let r = CGRect(x: _dTapStartP.x, y: _dTapStartP.y, width: p.x-_dTapStartP.x, height: p.y-_dTapStartP.y)
      dashDrawingView?.setDrawingRect(rect: r)
    }
  }
  
  
  override func touchesCancelled(_ touches: Set<UITouch>?, with event: UIEvent?) {
//    super.touchesCancelled(touches, withEvent: event)
    
    touchEnd()
  }
  
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//    super.touchesEnded(touches, withEvent: event)
    
    touchEnd()
  }
  
  
  private func touchEnd() {
    delegate?.drawRectEnded(doubleTapped: _dTapped)
    if _dTapped {
      _dTapped = false
      dashDrawingView?.clear()
      _lastTouch = nil
    }
  }
  
  private var _numVerticalLines   = 0
  private var _numHorizontalLines = 0
  var xInterval: CGFloat = 0
  var yInterval: CGFloat = 0
  
  
  override func draw(_ rect: CGRect) {
    
    var x: CGFloat =  0
    var y: CGFloat = 20
    
    for _ in 0 ..< _numVerticalLines {
      x += xInterval
      let bezier = UIBezierPath()
      bezier.move(to: CGPoint(x: x, y: y))
      bezier.addLine(to: CGPoint(x: x, y: self.frame.height-y))
      UIColor.gray.setStroke()
      bezier.lineWidth = 2
      bezier.stroke()
    }
    
    x = 20
    y = 0
    for _ in 0 ..< _numHorizontalLines {
      y += yInterval
      let bezier = UIBezierPath()
      bezier.move(to: CGPoint(x: x, y: y))
      bezier.addLine(to: CGPoint(x: self.frame.width-x, y: y))
      UIColor.gray.setStroke()
      bezier.lineWidth = 2
      bezier.stroke()
    }
  }
  
  
  func setNumberOfVerticalLines(num: Int) {
    
    setNeedsDisplay()
    
    _numVerticalLines = num
    
    if num > 0 {
      xInterval = self.frame.width / CGFloat(_numVerticalLines + 1)
    }
    
    PositionController.instance().setNumberOfVerticalLines(_numVerticalLines, interval: xInterval)
  }
  
  
  func setNumberOfHorizontalLines(num: Int) {
    
    setNeedsDisplay()
    
    _numHorizontalLines = num
    
    if num > 0 {
      yInterval = self.frame.height / CGFloat(_numHorizontalLines + 1)
    }
    
    PositionController.instance().setNumberOfHorizontalLines(_numHorizontalLines, interval: yInterval)
  }
}
