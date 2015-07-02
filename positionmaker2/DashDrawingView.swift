//
//  DashDrawingView.swift
//  positionmaker2
//
//  Created by Hiroki Taoka on 2015/06/23.
//  Copyright (c) 2015年 azukinohiroki. All rights reserved.
//

import Foundation
import UIKit

class DashDrawingView: UIView {
  
  private var _drawingRect = CGRectZero
  private var _draw = false
  
  override func drawRect(rect: CGRect) {
    if _draw {
      var bezier = UIBezierPath(rect: _drawingRect)
      UIColor.blackColor().setStroke()
      var pattern: [CGFloat] = [5, 5]
      bezier.setLineDash(pattern, count: 2, phase: 0)
      bezier.stroke()
    }
  }
  
  func setDrawingRect(rect: CGRect) {
    _draw = true
    _drawingRect = rect
    setNeedsDisplay()
  }
  
  func clear() {
    _draw = false
    _drawingRect = CGRectZero
    setNeedsDisplay()
  }
  
  func getDrawingRect() -> CGRect {
    return _drawingRect
  }
}