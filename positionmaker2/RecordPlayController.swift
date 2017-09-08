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
    return (UIApplication.shared.delegate as! AppDelegate).recordPlayController
  }
  

  private var _recording = false
  private var _record: [RecordPlayObject] = []
  private var _moved: [FigureView] = []
  
  
  func startRecording(_ figureViews: [FigureView]) {
    _record.removeAll(keepingCapacity: true)
    recordLocation(figureViews)
    _recording = true
  }
  
  
  func recordLocation(_ figureViews: [FigureView]) {
    
    let obj = RecordPlayObject(figureViews: figureViews)
    _record.append(obj)
    _moved.removeAll()
  }
  
  
  func clearRecord() {
    _record = []
  }
  
  
  func figureMoved(figureView fv: FigureView) {
    if let index = _moved.index(of: fv) {
      _moved.remove(at: index)
    }
    _moved.append(fv)
  }
  
  
  private var _playing = false
  private var _sleepInternval: UInt32 = 1
  
  
  func startPlaying(figureViews: [FigureView]) {
    
    if _record.count <= 1 || _playing {
      return;
    }
    
    _recording = false
    _playing   = true
    
    UIView.animate(withDuration: 1) {
      
      let first = self._record[0]
      for i in 0 ..< first.fvs.count {
        let fv = first.fvs[i]
        let p  = first.ps[i]
        fv.center = p
      }
    }
    
    DispatchQueue.global(qos: .userInitiated).async {
      sleep(1)
      self.startPlayInner()
    }
  }
  
  
  private func startPlayInner() {
    
    for index in 1 ..< _record.count {
      
      DispatchQueue.main.async {
        
        UIView.animate(withDuration: 1) {
          
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
