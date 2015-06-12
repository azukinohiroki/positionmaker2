//
//  ViewController.swift
//  positionmaker2
//
//  Created by Hiroki Taoka on 2015/06/10.
//  Copyright (c) 2015年 azukinohiroki. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, UIScrollViewDelegate {

  @IBOutlet var baseScrollView: MyScrollView!
  @IBOutlet var baseView: UIView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.baseScrollView.delegate = self
    
    var figure = Figure.defaultFigure()
    
    for i in 0..<5 {
      
      var frame = CGRectMake(CGFloat(i * 50), 0.0, 30.0, 30.0)
      var fv = FigureView(figure: figure, frame: frame)
    
      self.baseView.addSubview(fv)
    }
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  // MARK: UIScrollViewDelegate
  
  func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
    return self.baseView
  }
}