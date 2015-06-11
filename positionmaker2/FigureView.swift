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
  
  init(figure :Figure, frame: CGRect) {
    super.init(frame: frame)
    
    
    _figure = figure
    
    var red   = CGFloat((figure.color.intValue >> 16) & 0xFF)
    var green = CGFloat((figure.color.intValue >>  8) & 0xFF)
    var blue  = CGFloat( figure.color.intValue        & 0xFF)
    self.backgroundColor = UIColor(red: red/255.0, green: green/255.0, blue: blue/255.0, alpha: 1.0)
  }
}