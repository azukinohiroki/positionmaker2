//
//  Util.swift
//  positionmaker2
//
//  Created by Hiroki Taoka on 2016/07/30.
//  Copyright © 2016年 azukinohiroki. All rights reserved.
//

import Foundation

class Util {
  
  
  static func selectedFigureViewExcept(figureView: FigureView, figureViews: [FigureView]) -> [FigureView] {
    
    var fvs = [FigureView]()
    for fv in figureViews {
      if fv.selected && fv != figureView {
        fvs.append(fv)
      }
    }
    return fvs
  }
}