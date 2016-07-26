//
//  RecordPlayController.swift
//  positionmaker2
//
//  Created by Hiroki Taoka on 2015/07/02.
//  Copyright (c) 2015年 azukinohiroki. All rights reserved.
//

import Foundation
import UIKit

class RecordPlayObject {
  var fvs: [FigureView]
  var ps : [CGPoint]
  init(figureViews: [FigureView]) {
    fvs = figureViews
    ps  = []
    for fv in fvs {
      ps.append(fv.center)
    }
  }
}

class RecordPlayController {
  
  static func instance() -> RecordPlayController {
    return (UIApplication.sharedApplication().delegate as! AppDelegate).recordPlayController
  }
  

  private var _recording = false
  private var _record: [RecordPlayObject] = []
  
  func startRecording(figureViews: [FigureView]) {
    _record.removeAll(keepCapacity: true)
    _record.append(RecordPlayObject(figureViews: figureViews))
    _recording = true
  }
  
  func recordLocation(figureViews: [FigureView]) {
    
    let obj = RecordPlayObject(figureViews: figureViews)
    _record.append(obj)
  }
  
  func clearRecord() {
    _record = []
  }
  
  
  private var _playing = false
  private var _sleepInternval: UInt32 = 1
  
  func startPlaying(figureViews: [FigureView]) {
    
    if _record.count <= 1 || _playing {
      return;
    }
    
    _recording = false
    _playing   = true
    
    UIView.animateWithDuration(1) {
      
      let first = self._record[0]
      for i in 0 ..< first.fvs.count {
        let fv = first.fvs[i]
        let p  = first.ps[i]
        fv.center = p
      }
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
      sleep(1)
      self.startPlayInner()
    }
  }
  
  private func startPlayInner() {
    
    for index in 1 ..< _record.count {
      
      dispatch_async(dispatch_get_main_queue()) {
        
        UIView.animateWithDuration(1) {
          
          let first = self._record[index]
          for i in 0 ..< first.fvs.count {
            let fv = first.fvs[i]
            let p  = first.ps[i]
            fv.center = p
          }
        }
      }
      
      sleep(_sleepInternval)
    }
    _playing = false
  }
}