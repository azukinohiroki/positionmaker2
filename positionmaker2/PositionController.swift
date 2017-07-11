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
    return (UIApplication.shared.delegate as! AppDelegate).positionController
  }
  
  
  private var _numVLines = 0, _numHLines = 0
  private var _vInterval = CGFloat(0), _hInterval = CGFloat(0)
  
  func setNumberOfVerticalLines(_ num: Int, interval: CGFloat) {
    _numVLines = num
    _vInterval = interval
  }
  
  
  func setNumberOfHorizontalLines(_ num: Int, interval: CGFloat) {
    _numHLines = num
    _hInterval = interval
  }
  
  
  func arrangePosition(_ fv: FigureView, figureViews: [FigureView]) {
    
    let fvs = Util.selectedFigureViewExcept(fv, figureViews: figureViews)
    fv.center = getArrangedPosition(fv.center)
    for v in fvs {
      v.center = getArrangedPosition(v.center)
    }
  }
  
  
  private func getArrangedPosition(_ p: CGPoint) -> CGPoint {
    
    var ret            = CGPoint()
    var diffx: CGFloat = CGFloat.greatestFiniteMagnitude
    
    if _numVLines == 0 {
      diffx = 0
      
    } else {
      for i in 1 ... _numVLines {
        let x: CGFloat = _vInterval * CGFloat(i)
        if abs(diffx) < abs(x - p.x) {
          break
        }
        diffx = x - p.x
      }
    }
    
    ret.x = p.x + diffx
    
    var diffy: CGFloat = CGFloat.greatestFiniteMagnitude

    if _numHLines == 0 {
      diffy = 0
      
    } else {
      for i in 1 ... _numHLines {
        let y: CGFloat = _hInterval * CGFloat(i)
        if abs(diffy) < abs(y - p.y) {
          break
        }
        diffy = y - p.y
      }
    }
    
    ret.y = p.y + diffy
    
    return ret;
  }
}
