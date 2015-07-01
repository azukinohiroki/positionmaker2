//
//  ActionLogController.swift
//  positionmaker2
//
//  Created by Hiroki Taoka on 2015/06/19.
//  Copyright (c) 2015年 azukinohiroki. All rights reserved.
//

import Foundation
import UIKit

enum ActionLogType: Int {
  case MOVE
  case MULTI_MOVE
  case DELETE
  case LABEL_CHANGE
}

class ActionLogObject {
  var type: ActionLogType
  init(type: ActionLogType) {
    self.type = type
  }
}

class MoveObject : ActionLogObject {
  var from: CGPoint
  var to:   CGPoint
  var fv:   FigureView
  init(from: CGPoint, to: CGPoint, fv: FigureView) {
    self.from = from
    self.to   = to
    self.fv   = fv
    super.init(type: .MOVE)
  }
}

class MultiMoveObject : MoveObject {
  var fvs:  [FigureView]
  init(from: CGPoint, to: CGPoint, fv: FigureView, fvs: [FigureView]) {
    self.fvs  = fvs
    super.init(from: from, to: to, fv: fv)
    self.type = .MULTI_MOVE
  }
}

class DeleteObject : ActionLogObject {
  var fv: FigureView
  var vc: ViewController
  init(fv: FigureView, vc: ViewController) {
    self.fv = fv
    self.vc = vc
    super.init(type: .DELETE)
  }
}

class LabelChangeObject : ActionLogObject {
  var from: String
  var to:   String
  var fv:   FigureView
  init(from: String, to:String, fv: FigureView) {
    self.from = from
    self.to   = to
    self.fv   = fv
    super.init(type: .LABEL_CHANGE)
  }
}

class ActionLogController {
  
  private let _undoLog: NSMutableArray = NSMutableArray()
  private let _redoLog: NSMutableArray = NSMutableArray()
  
  func addMove(#from: CGPoint, to: CGPoint, fv:FigureView) {
    var dat = MoveObject(from: from, to: to, fv: fv)
    save(dat)
  }
  
  func addMultiMove(#from: CGPoint, to: CGPoint, fv: FigureView, fvs: [FigureView]) {
    var dat = MultiMoveObject(from: from, to: to, fv: fv, fvs: fvs)
    save(dat)
  }
  
  func addDelete(#fv: FigureView, origin: CGPoint, vc: ViewController) {
    var frame = fv.frame
    fv.frame = CGRectMake(origin.x, origin.y, CGRectGetWidth(frame), CGRectGetHeight(frame))
    var dat = DeleteObject(fv: fv, vc: vc)
    save(dat)
  }
  
  func addLabelChange(#from: String, to: String, fv:FigureView) {
    var dat = LabelChangeObject(from: from, to: to, fv: fv)
    save(dat)
  }
  
  private func save(dat: ActionLogObject) {
    _undoLog.addObject(dat)
    _redoLog.removeAllObjects()
  }
  
  func undo() -> ActionLogObject? {
    if _undoLog.count == 0 { return nil }
    var log = _undoLog.lastObject as! ActionLogObject
    _undoLog.removeObject(log)
    _redoLog.addObject(log)
    
    switch log.type {
    case .MOVE:
      var move = log as! MoveObject
      var size = move.fv.frame.size
      move.fv.frame = CGRectMake(move.from.x, move.from.y, size.width, size.height)
      move.fv.checkOverlaps()
      
    case .MULTI_MOVE:
      var move = log as! MultiMoveObject
      var size = move.fv.frame.size
      move.fv.frame = CGRectMake(move.from.x, move.from.y, size.width, size.height)
      var dx = move.to.x - move.from.x
      var dy = move.to.y - move.from.y
      for fv in move.fvs {
        fv.center = CGPointMake(fv.center.x - dx, fv.center.y - dy)
        fv.checkOverlaps()
      }
      
    case .DELETE:
      var del = log as! DeleteObject
      del.vc.addFVToList(del.fv)
      del.vc.baseView.addSubview(del.fv)
      // FIXME: DB
      
    case .LABEL_CHANGE:
      var lbl = log as! LabelChangeObject
      lbl.fv.setLabel(lbl.from)
    }

    return log
  }
  
  func redo() -> ActionLogObject? {
    if _redoLog.count == 0 { return nil }
    var log = _redoLog.lastObject as! ActionLogObject
    _redoLog.removeObject(log)
    _undoLog.addObject(log)
    
    switch log.type {
    case .MOVE:
      var move = log as! MoveObject
      var size = move.fv.frame.size
      move.fv.frame = CGRectMake(move.to.x, move.to.y, size.width, size.height)
      move.fv.checkOverlaps()
      
    case .MULTI_MOVE:
      var move = log as! MultiMoveObject
      var size = move.fv.frame.size
      move.fv.frame = CGRectMake(move.to.x, move.to.y, size.width, size.height)
      var dx = move.to.x - move.from.x
      var dy = move.to.y - move.from.y
      for fv in move.fvs {
        fv.center = CGPointMake(fv.center.x + dx, fv.center.y + dy)
        fv.checkOverlaps()
      }
      
    case .DELETE:
      var del = log as! DeleteObject
      del.fv.removeFromSuperview()
      del.vc.removeFVFromList(del.fv)
      // FIXME: DB
      
    case .LABEL_CHANGE:
      var lbl = log as! LabelChangeObject
      lbl.fv.setLabel(lbl.to)
    }
    
    return log
  }
}