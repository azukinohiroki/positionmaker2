//
//  FigureView.swift
//  positionmaker2
//
//  Created by Hiroki Taoka on 2015/06/11.
//  Copyright (c) 2015年 azukinohiroki. All rights reserved.
//

import Foundation
import UIKit
import SCLAlertView



protocol FigureViewDelegate : class {
  func startTouch(view: FigureView, touch: UITouch) -> UIView?
  func endTouch(view: FigureView, beganPoint: CGPoint)
}



class FigureView: UIView, UITextFieldDelegate {
  
  private var _figure: Figure!
  private var _parent: UIView?
  private var _vc: ViewController!
  
  private let _label: UITextField!
  
  weak var delegate: FigureViewDelegate? = nil
  
  var selected: Bool = false {
    didSet {
      self.selected ? self.backgroundColor = UIColor.lightGrayColor() : setColor(_figure)
    }
  }
  
  
  required init(coder aDecoder: NSCoder) {
    
    _label       = UITextField()
    super.init(coder: aDecoder)
  }
  
  init(figure: Figure, vc: ViewController, frame: CGRect) {
    
    _label       = UITextField()
    super.init(frame: frame)
    
    initFigureView(figure, vc: vc, frame: frame)
  }
  
  init(figure: Figure, vc: ViewController) {
    
    var frame = CGRect(origin: CGPointZero, size: CGSizeMake(30, 30))
    _label    = UITextField()
    super.init(frame: frame)
    
    initFigureView(figure, vc: vc, frame: frame)
  }
  
  
  private func initFigureView(figure: Figure, vc: ViewController, frame: CGRect) {
    _vc  = vc
    setFigure(figure)
//    _startingPoint = frame.origin
    
    var gr = UITapGestureRecognizer(target: self, action: NSSelectorFromString("handleTap:"))
    gr.numberOfTapsRequired    = 1
    gr.numberOfTouchesRequired = 1
    addGestureRecognizer(gr)
    
    var long = UILongPressGestureRecognizer(target: self, action: NSSelectorFromString("handleLongPress:"))
    long.minimumPressDuration = 0.8
    addGestureRecognizer(long)
    
    var dbl = UITapGestureRecognizer(target: self, action: NSSelectorFromString("handleDoubleTap:"))
    dbl.numberOfTapsRequired    = 2
    dbl.numberOfTouchesRequired = 1
    addGestureRecognizer(dbl)
    
    _label.frame = CGRectMake(0, 0, frame.size.width, frame.size.height)
    _label.userInteractionEnabled    = false
    _label.delegate = self
    addSubview(_label)
  }
  
  private func setFigure(figure: Figure) {
    
    _figure = figure
    setColor(figure)
  }
  
  private func setColor(figure: Figure) {
    var color = figure.color.intValue
    var red   = CGFloat((color >> 16) & 0xFF)
    var green = CGFloat((color >>  8) & 0xFF)
    var blue  = CGFloat( color        & 0xFF)
    self.backgroundColor = UIColor(red: red/255.0, green: green/255.0, blue: blue/255.0, alpha: 1.0)
  }
  
  func handleTap(sender: UITapGestureRecognizer) {
    if sender.state == .Ended && !_moved {
      selected = !selected
//      println("tapped+\(selected)")
    }
  }
  
  private var _longPressed = false
  
  func handleLongPress(sender: UILongPressGestureRecognizer) {
    if sender.state == .Began {
      _longPressed = true
      var alert = SCLAlertView()
      alert.addButton("OK", action: { () -> Void in
        self.removeFromSuperview()
        self._vc.removeFVFromList(self)
        ActionLogController.instance().addDelete(fv: self, origin: self._beganPoint, vc: self._vc)
        // FIXME: DBとの連携
      })
      alert.showWarning("確認", subTitle: "削除しますか？", closeButtonTitle: "CANCEL")
      
    } else if sender.state == .Ended {
      _longPressed = false
    }
  }
  
  private var _lastLabel = ""
  
  func handleDoubleTap(sender: UITapGestureRecognizer) {
    selected = false
    _label.userInteractionEnabled = true
    if _label.canBecomeFirstResponder() {
      _label.becomeFirstResponder()
      _lastLabel = _label.text
    }
  }
  
  func setLabel(text: String) {
    _label.text = text
    fitFontSize(_label)
  }
  
  
  private var _beganPoint: CGPoint = CGPointZero
  private var _lastTouched: CGPoint = CGPointZero
  private var _moved: Bool = false
  
  override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
    //    super.touchesBegan(touches, withEvent: event)
    
    _moved = false
    
    if let del = delegate {
      var touch = touches.first as! UITouch
      _parent = del.startTouch(self, touch: touch)
      _lastTouched = touch.locationInView(_parent)
      _beganPoint  = frame.origin
    }
  }
  
  override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
    //    super.touchesMoved(touches, withEvent: event)
    
    _moved = true
    
    if let parent = _parent {
      var touch = touches.first as! UITouch
      var point = touch.locationInView(parent)
      var dx = _lastTouched.x - point.x
      var dy = _lastTouched.y - point.y
      
      var center  = self.center
      self.center = CGPointMake(center.x - dx, center.y - dy)
      moveOthers(dx, dy)
      
      _lastTouched = point
    }
  }
  
  func moveOthers(dx: CGFloat, _ dy: CGFloat) {
    for fv in _vc.figureViews {
      if !fv.selected || fv == self { continue }
      var center = fv.center
      fv.center  = CGPointMake(center.x - dx, center.y - dy)
    }
  }
  
  override func touchesCancelled(touches: Set<NSObject>!, withEvent event: UIEvent!) {
    //    super.touchesCancelled(touches, withEvent: event)
    
    endTouch()
    _parent = nil;
  }
  
  override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
    //    super.touchesEnded(touches, withEvent: event)
    
    endTouch()
    _parent = nil;
  }
  
  private var _overlapFVs: [FigureView] = []
  
  func endTouch() {
    
    checkOverlaps()
    checkOthersOverlap()
    
    if !_longPressed && _moved {
      delegate?.endTouch(self, beganPoint: _beganPoint)
    }
    
    _moved = false
  }
  
  func checkOverlaps() {
    
    var oldOverlaps = _overlapFVs
    for fv in oldOverlaps {
      fv.requestDeleteFV(self)
    }
    
    _overlapFVs = [FigureView]()
    for fv in _vc.figureViews {
      if self == fv { continue; }
      if CGRectContainsPoint(self.frame, fv.center) {
//      if CGRectIntersectsRect(self.frame, fv.frame) {
        _overlapFVs.append(fv)
        self.alpha = 0.5
        fv.alpha   = 0.5
      }
    }
    
    if _overlapFVs.isEmpty {
      self.alpha = 1
      
    } else {
      for fv in _overlapFVs {
        fv.requestAddFV(self)
      }
      _overlapFVs.append(self)
    }
    
  }
  
  func requestAddFV(fv: FigureView) {
    if _overlapFVs.isEmpty {
      _overlapFVs = [self, fv]
      
    } else {
      _overlapFVs.append(fv)
    }
  }
  
  func requestDeleteFV(fv: FigureView) {
    if _overlapFVs.isEmpty {
      return
      
    } else {
      _overlapFVs = _overlapFVs.filter() { $0 != fv }
      if _overlapFVs.count == 1 {
        _overlapFVs.removeAll(keepCapacity: true)
        alpha = 1
      }
    }
  }
  
  func checkOthersOverlap() {
    for fv in _vc.figureViews {
      if !fv.selected || self == fv { continue }
      fv.checkOverlaps()
    }
  }
  
  
  
  // MARK: UITextFieldDelegate
  
  func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
    textField.font = UIFont.systemFontOfSize(UIFont.systemFontSize())
    return true
  }
  
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    textField.userInteractionEnabled = false
    return false
  }
  
  func textFieldDidEndEditing(textField: UITextField) {
    fitFontSize(textField)
    ActionLogController.instance().addLabelChange(from: _lastLabel, to: textField.text, fv: self)
  }
  
  private func fitFontSize(textField: UITextField) {
    var frame = textField.frame
    textField.sizeToFit()
    if checkFontSize(textField, frame) {
      textField.frame = frame
      return
    }
    textField.frame = frame
    
    var font = textField.font.pointSize
    if  font < 1 {
      textField.font = UIFont.systemFontOfSize(UIFont.systemFontSize())
      return
    }
    
    --font
    textField.font = UIFont.systemFontOfSize(font)
    
    fitFontSize(textField)
  }
  
  private func checkFontSize(tf: UITextField, _ frame: CGRect) -> Bool {
    var size1 = tf.frame.size
    var size2 = frame.size
    return CGSizeEqualToSize(size1, size2) || (size1.width < size2.width && size1.height < size2.height)
  }
}