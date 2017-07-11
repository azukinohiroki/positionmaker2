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
  
  
  static func instance() -> ActionLogController {
    return (UIApplication.shared.delegate as! AppDelegate).actionLogController
  }
  
  
  func addMove(from: CGPoint, moved: FigureView, figureViews: [FigureView]) {
    
    let fvs = Util.selectedFigureViewExcept(moved, figureViews: figureViews)
    let o   = moved.frame.origin
    if fvs.isEmpty {
      addMove(from: from, to: o, fv: moved)
    } else {
      addMultiMove(from: from, to: o, fv: moved, fvs: fvs)
    }
  }
  
  
  private func addMove(from: CGPoint, to: CGPoint, fv:FigureView) {
    let dat = MoveObject(from: from, to: to, fv: fv)
    save(dat: dat)
  }
  
  
  private func addMultiMove(from: CGPoint, to: CGPoint, fv: FigureView, fvs: [FigureView]) {
    let dat = MultiMoveObject(from: from, to: to, fv: fv, fvs: fvs)
    save(dat: dat)
  }
  
  
  func addDelete(fv: FigureView, origin: CGPoint, vc: ViewController) {
    let frame = fv.frame
    fv.frame = CGRect(x: origin.x, y: origin.y, width: frame.width, height: frame.height)
    let dat = DeleteObject(fv: fv, vc: vc)
    save(dat: dat)
  }
  
  
  func addLabelChange(from: String, to: String, fv:FigureView) {
    let dat = LabelChangeObject(from: from, to: to, fv: fv)
    save(dat: dat)
  }
  
  
  private func save(dat: ActionLogObject) {
    _undoLog.add(dat)
    _redoLog.removeAllObjects()
  }
  
  
  func undo() -> ActionLogObject? {
    if _undoLog.count == 0 { return nil }
    let log = _undoLog.lastObject as! ActionLogObject
    _undoLog.remove(log)
    _redoLog.add(log)
    
    switch log.type {
    case .MOVE:
      let move = log as! MoveObject
      let size = move.fv.frame.size
      move.fv.frame = CGRect(x: move.from.x, y: move.from.y, width: size.width, height: size.height)
      move.fv.checkOverlaps()
      
    case .MULTI_MOVE:
      let move = log as! MultiMoveObject
      let size = move.fv.frame.size
      move.fv.frame = CGRect(x: move.from.x, y: move.from.y, width: size.width, height: size.height)
      let dx = move.to.x - move.from.x
      let dy = move.to.y - move.from.y
      for fv in move.fvs {
        fv.center = CGPoint(x: fv.center.x - dx, y: fv.center.y - dy)
        fv.checkOverlaps()
      }
      
    case .DELETE:
      let del = log as! DeleteObject
      del.vc.addFVToList(del.fv)
      del.vc.baseView.addSubview(del.fv)
      // FIXME: DB
      
    case .LABEL_CHANGE:
      let lbl = log as! LabelChangeObject
      lbl.fv.setLabel(lbl.from)
    }

    return log
  }
  
  
  func redo() -> ActionLogObject? {
    if _redoLog.count == 0 { return nil }
    let log = _redoLog.lastObject as! ActionLogObject
    _redoLog.remove(log)
    _undoLog.add(log)
    
    switch log.type {
    case .MOVE:
      let move = log as! MoveObject
      let size = move.fv.frame.size
      move.fv.frame = CGRect(x: move.to.x, y: move.to.y, width: size.width, height: size.height)
      move.fv.checkOverlaps()
      
    case .MULTI_MOVE:
      let move = log as! MultiMoveObject
      let size = move.fv.frame.size
      move.fv.frame = CGRect(x: move.to.x, y: move.to.y, width: size.width, height: size.height)
      let dx = move.to.x - move.from.x
      let dy = move.to.y - move.from.y
      for fv in move.fvs {
        fv.center = CGPoint(x: fv.center.x + dx, y: fv.center.y + dy)
        fv.checkOverlaps()
      }
      
    case .DELETE:
      let del = log as! DeleteObject
      del.fv.removeFromSuperview()
      del.vc.removeFVFromList(del.fv)
      // FIXME: DB
      
    case .LABEL_CHANGE:
      let lbl = log as! LabelChangeObject
      lbl.fv.setLabel(lbl.to)
    }
    
    return log
  }
}
