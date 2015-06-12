//
//  FigureView.swift
//  positionmaker2
//
//  Created by Hiroki Taoka on 2015/06/11.
//  Copyright (c) 2015年 azukinohiroki. All rights reserved.
//

import Foundation
import UIKit

class FigureView: UIView {
  
  private var _figure: Figure?
  
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
}