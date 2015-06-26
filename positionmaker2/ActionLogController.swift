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

class ActionLogController {
  
  private let _undoLog: NSMutableArray = NSMutableArray()
  private let _redoLog: NSMutableArray = NSMutableArray()
  
  func addMove(#from: CGPoint, to: CGPoint, fv:FigureView) {
    var dat = MoveObject(from: from, to: to, fv: fv)
    _undoLog.addObject(dat)
    _redoLog.removeAllObjects()
  }
  
  func addMultiMove(#from: CGPoint, to: CGPoint, fv: FigureView, fvs: [FigureView]) {
    var dat = MultiMoveObject(from: from, to: to, fv: fv, fvs: fvs)
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
    }
    
    return log
  }
}