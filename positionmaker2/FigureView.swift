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
import SwiftHSVColorPicker



protocol FigureViewDelegate : class {
  func startTouch(view: FigureView, touch: UITouch) -> UIView?
  func endTouch(view: FigureView, beganPoint: CGPoint)
}



private extension Selector {
  static let handleTap       = #selector(FigureView.handleTap(_:))
  static let handleLongPress = #selector(FigureView.handleLongPress(_:))
  static let handleDoubleTap = #selector(FigureView.handleDoubleTap(_:))
}



class FigureView: UIView, UITextFieldDelegate, SphereMenuDelegate {
  
  private var _figure: Figure!
  private var _parent: UIView?
  private var _vc: ViewController!
  
  private var _r: CGFloat = 1.0, _g: CGFloat = 1.0, _b: CGFloat = 1.0, _a: CGFloat = 1.0
  
  private let _label: UITextField!
  
  weak var delegate: FigureViewDelegate? = nil
  
  var selected: Bool = false {
    didSet {
//      self.selected ? self.backgroundColor = UIColor.lightGrayColor() : setColor(_figure)
      if self.selected {
        _r = 0.7
        _g = 0.7
        _b = 0.7
        setNeedsDisplay()
        
      } else {
        setColor(_figure)
      }
    }
  }
  
  
  required init?(coder aDecoder: NSCoder) {
    
    _label       = UITextField()
    super.init(coder: aDecoder)
  }
  
  init(figure: Figure, vc: ViewController, frame: CGRect) {
    
    _label       = UITextField()
    super.init(frame: frame)
    
    initFigureView(figure, vc: vc, frame: frame)
  }
  
  init(figure: Figure, vc: ViewController) {
    
    let frame = CGRect(origin: CGPointZero, size: CGSizeMake(30, 30))
    _label    = UITextField()
    super.init(frame: frame)
    
    initFigureView(figure, vc: vc, frame: frame)
  }
  
  
  private func initFigureView(figure: Figure, vc: ViewController, frame: CGRect) {
    _vc  = vc
    setFigure(figure)
//    _startingPoint = frame.origin
    
    let gr = UITapGestureRecognizer(target: self, action: .handleTap)
    gr.numberOfTapsRequired    = 1
    gr.numberOfTouchesRequired = 1
    addGestureRecognizer(gr)
    
    let long = UILongPressGestureRecognizer(target: self, action: .handleLongPress)
    long.minimumPressDuration = 0.8
    addGestureRecognizer(long)
    
    let dbl = UITapGestureRecognizer(target: self, action: .handleDoubleTap)
    dbl.numberOfTapsRequired    = 2
    dbl.numberOfTouchesRequired = 1
    addGestureRecognizer(dbl)
    
    _label.frame = CGRectMake(0, 0, frame.size.width, frame.size.height)
    _label.userInteractionEnabled    = false
    _label.delegate = self
    addSubview(_label)
    
    self.backgroundColor = UIColor.clearColor()
  }
  
  
  private func setFigure(figure: Figure) {
    
    _figure = figure
    setColor(figure)
  }
  
  
  private func setColor(figure: Figure) {
    let color = figure.color.intValue
    _r = CGFloat((color >> 16) & 0xFF) / 255.0
    _g = CGFloat((color >>  8) & 0xFF) / 255.0
    _b = CGFloat( color        & 0xFF) / 255.0
    setNeedsDisplay()
  }
  
  
  override func drawRect(rect: CGRect) {
    let ctx: CGContextRef = UIGraphicsGetCurrentContext()!
    CGContextSetRGBFillColor(ctx, 0.5, 0.5, 0.5, 1.0)
    CGContextSetRGBStrokeColor(ctx, _r, _g, _b, _a)
    CGContextStrokeEllipseInRect(ctx, CGRectMake(0, 0, frame.size.width*0.9, frame.size.height*0.9))
    CGContextFillEllipseInRect(ctx,   CGRectMake(0, 0, frame.size.width*0.9, frame.size.height*0.9))
    CGContextSetRGBFillColor(ctx,   _r, _g, _b, _a)
    CGContextFillEllipseInRect(ctx,   CGRectMake(0, 0, frame.size.width*0.9, frame.size.height*0.8))
  }
  
  
  
  // MARK: UI event delegate
  
  func handleTap(sender: UITapGestureRecognizer) {
    if sender.state == .Ended && !_moved {
      selected = !selected
//      println("tapped+\(selected)")
    }
  }
  
  
  private var _longPressed = false
  
  func handleLongPress(sender: UILongPressGestureRecognizer) {
    if sender.state == .Began {
      if _moved { return; }
      _longPressed = true
      let alert = SCLAlertView()
      alert.addButton("削除") {
        self.removeFromSuperview()
        self._vc.removeFVFromList(self)
        ActionLogController.instance().addDelete(fv: self, origin: self._beganPoint, vc: self._vc)
        // FIXME: DBとの連携
      }
      alert.addButton("色変更") {
        let start = UIImage(named: "start")
        let image1 = UIImage(named: "icon-facebook")
        let image2 = UIImage(named: "icon-email")
        let image3 = UIImage(named: "icon-twitter")
        let images:[UIImage] = [image1!,image2!,image3!]
        let menu = SphereMenu(startPoint: CGPointMake(160, 320), startImage: start!, submenuImages:images, tapToDismiss:true)
        menu.delegate = self
        self._vc.baseView.addSubview(menu)
      }
      /*alert.addButton("色変更2") {
        var colorWell:ColorWell = ColorWell()
        var colorPicker:ColorPicker = ColorPicker()
        var huePicker:HuePicker = HuePicker()
        
        // Setup
        var pickerController = ColorPickerController(svPickerView: colorPicker, huePickerView: huePicker, colorWell: colorWell)
        pickerController.color = UIColor.redColor()
        
        // get color:
        pickerController.color
        
        // get color updates:
        pickerController.onColorChange = {(color, finished) in
          if finished {
            self.view.backgroundColor = UIColor.whiteColor() // reset background color to white
          } else {
            self.view.backgroundColor = color // set background color to current selected color (finger is still down)
          }
        }
      }*/
      alert.showWarning("メニュー", subTitle: "選択してください", closeButtonTitle: "CANCEL")
      
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
      _lastLabel = _label.text!
    }
  }
  
  
  func setLabel(text: String) {
    _label.text = text
    fitFontSize(_label)
  }
  
  
  private var _beganPoint: CGPoint = CGPointZero
  private var _lastTouched: CGPoint = CGPointZero
  private var _moved: Bool = false
  
  override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    //    super.touchesBegan(touches, withEvent: event)
    
    _moved = false
    
    if let del = delegate {
      let touch = touches.first as UITouch!
      _parent = del.startTouch(self, touch: touch)
      _lastTouched = touch.locationInView(_parent)
      _beganPoint  = frame.origin
    }
  }
  
  
  override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
    //    super.touchesMoved(touches, withEvent: event)
    
    _moved = true
    
    if let parent = _parent {
      let touch = touches.first as UITouch!
      let point = touch.locationInView(parent)
      let dx = _lastTouched.x - point.x
      let dy = _lastTouched.y - point.y
      
      let center  = self.center
      self.center = CGPointMake(center.x - dx, center.y - dy)
      moveOthers(dx, dy)
      
      _lastTouched = point
    }
  }
  
  
  func moveOthers(dx: CGFloat, _ dy: CGFloat) {
    for fv in _vc.figureViews {
      if !fv.selected || fv == self { continue }
      let center = fv.center
      fv.center  = CGPointMake(center.x - dx, center.y - dy)
    }
  }
  
  
  override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
    //    super.touchesCancelled(touches, withEvent: event)
    
    endTouch()
    _parent = nil;
  }
  
  
  override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
    //    super.touchesEnded(touches, withEvent: event)
    
    endTouch()
    _parent = nil;
  }
  
  
  private var _overlapFVs: [FigureView] = []
  
  func endTouch() {
    
    if !_longPressed && _moved {
      delegate?.endTouch(self, beganPoint: _beganPoint)
      
      let alc = ActionLogController.instance()
      alc.addMove(from: _beganPoint, moved: self, figureViews: _vc.figureViews)
    }
    
//    center = PositionController.instance().getArrangedPosition(center)
    PositionController.instance().arrangePosition(self, figureViews: _vc.figureViews)
    
    checkOverlaps()
    checkOthersOverlap()
    
    _moved = false
  }
  
  
  func checkOverlaps() {
    
    let oldOverlaps = _overlapFVs
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
  
  
  func checkOthersOverlap() {
    for fv in _vc.figureViews {
      if !fv.selected || self == fv { continue }
      fv.checkOverlaps()
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
    ActionLogController.instance().addLabelChange(from: _lastLabel, to: textField.text!, fv: self)
  }
  
  private func fitFontSize(textField: UITextField) {
    let frame = textField.frame
    textField.sizeToFit()
    if checkFontSize(textField, frame) {
      textField.frame = frame
      return
    }
    textField.frame = frame
    
    var font = textField.font!.pointSize
    if  font < 1 {
      textField.font = UIFont.systemFontOfSize(UIFont.systemFontSize())
      return
    }
    
    --font
    textField.font = UIFont.systemFontOfSize(font)
    
    fitFontSize(textField)
  }
  
  private func checkFontSize(tf: UITextField, _ frame: CGRect) -> Bool {
    let size1 = tf.frame.size
    let size2 = frame.size
    return CGSizeEqualToSize(size1, size2) || (size1.width < size2.width && size1.height < size2.height)
  }
  
  
  
  // MARK: SphereMenuDelegate
  
  func sphereDidSelected(index: Int, menu: SphereMenu) {
    NSLog("sphereDidSelected:%d", index)
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(3 * NSEC_PER_SEC)), dispatch_get_main_queue()) {
      menu.hide()
//    }
  }
}
