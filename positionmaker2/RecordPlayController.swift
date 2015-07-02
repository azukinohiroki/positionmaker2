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
  
  static func recordPlayController() -> RecordPlayController {
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
    
    var obj = RecordPlayObject(figureViews: figureViews)
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
      
      var first = self._record[0]
      for i in 0 ..< first.fvs.count {
        var fv = first.fvs[i]
        var p  = first.ps[i]
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
          
          var first = self._record[index]
          for i in 0 ..< first.fvs.count {
            var fv = first.fvs[i]
            var p  = first.ps[i]
            fv.center = p
          }
        }
      }
      
      sleep(_sleepInternval)
    }
    _playing = false

    
    
    
    
    
    
    
    
    
//    var index = 0
//    while self._playing {
//      if self._recordedMotion.count <= index {
//        self._playing = false
//        return
//      }
//      
//      var array = self._recordedMotion[index]
//      if array.count == 0 {
//        continue
//      }
//      
//      self.playASequence(array)
//      ++index
//    }
  }
  
//  private func playASequence(array: [CGPoint]) {
//    //    _recording = false
//    var interval = 1//_vc.playInterval
//    var count = array.count
//    
//    if count == 0 { return }
//    
//    var wait = (interval * 50000) / count
//    
//    for p in array {
//      
//      dispatch_async(dispatch_get_main_queue(), { () -> Void in
//        self.center = CGPointMake(self.center.x - p.x, self.center.y - p.y)
//        return
//      })
//
//      usleep(UInt32(wait))
//    }
//  }

}