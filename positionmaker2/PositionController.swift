//
//  PositionController.swift
//  positionmaker2
//
//  Created by Hiroki Taoka on 2016/07/29.
//  Copyright © 2016年 azukinohiroki. All rights reserved.
//

import Foundation
import UIKit

class PositionController {
  
  
  static func instance() -> PositionController {
    return (UIApplication.sharedApplication().delegate as! AppDelegate).positionController
  }
  
  
  private var _numVLines = 0, _numHLines = 0
  private var _vInterval = CGFloat(0), _hInterval = CGFloat(0)
  
  func setNumberOfVerticalLines(num: Int, interval: CGFloat) {
    _numVLines = num
    _vInterval = interval
  }
  
  
  func setNumberOfHorizontalLines(num: Int, interval: CGFloat) {
    _numHLines = num
    _hInterval = interval
  }
  
  
  func arrangePosition(fv: FigureView, figureViews: [FigureView]) {
    
    let fvs = Util.selectedFigureViewExcept(fv, figureViews: figureViews)
    fv.center = getArrangedPosition(fv.center)
    for v in fvs {
      v.center = getArrangedPosition(v.center)
    }
  }
  
  
  private func getArrangedPosition(p: CGPoint) -> CGPoint {
    
    if _numVLines == 0 && _numHLines == 0 {
      return p
    }
    
    var ret            = CGPoint()
    var diffx: CGFloat = CGFloat.max
    
    for i in 1 ... _numVLines {
      let x: CGFloat = _vInterval * CGFloat(i)
      if abs(diffx) < abs(x - p.x) {
        break
      }
      diffx = x - p.x
    }
    
    ret.x = p.x + diffx
    
    var diffy: CGFloat = CGFloat.max
    
    for i in 1 ... _numHLines {
      let y: CGFloat = _hInterval * CGFloat(i)
      if abs(diffy) < abs(y - p.y) {
        break
      }
      diffy = y - p.y
    }
    
    ret.y = p.y + diffy
    
    return ret;
  }
}