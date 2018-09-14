//
//  SaveLoadController.swift
//  positionmaker2
//
//  Created by Hiroki Taoka on 2017/09/08.
//  Copyright © 2017年 azukinohiroki. All rights reserved.
//

import Foundation
import UIKit

class SaveLoadController {
  
  static func instance() -> SaveLoadController {
    return (UIApplication.shared.delegate as! AppDelegate).saveLoadController
  }
  
  func startSave(_ figureViews: [FigureView]) {
    
    var dic = Dictionary<String, Any>()
    dic["figureView"] = collectFigureViews(figureViews: figureViews)
//    dic["actionLog"]  = ActionLogController.instance().toDictionary() // comment out on this time...
//    dic["recordPlay"] = RecordPlayController.instance().toDictionary()

    do {
      let jsonData = try JSONSerialization.data(withJSONObject: dic, options: [])
      let jsonStr  = String(bytes: jsonData, encoding: .utf8)
      print(jsonStr ?? "empty")
      
      let path = Util.documentDirectoryPath() + "/saved.json"
      NSData(data: jsonData).write(toFile: path, atomically: true)
      
    } catch let err {
      print(err)
    }
  }
  
  private func collectFigureViews(figureViews: [FigureView]) -> Dictionary<String, Array<Dictionary<String, Any>>> {
    
    var fvArr = Array<Dictionary<String, Any>>()
    for fv in figureViews {
      let dic = fv.toDictionary()
      fvArr.append(dic)
    }
    
    return ["figureView": fvArr]
  }
  
  func startLoad(_ vc: ViewController) {
    
    do {
      let path = Util.documentDirectoryPath() + "/saved.json"
      let tmpData  = NSData(contentsOfFile: path)!
      let jsonData = Data(bytes:tmpData.bytes, count:tmpData.length)
      let jsonStr  = String(bytes: jsonData, encoding: .utf8)
      print(jsonStr ?? "empty")
      
      let dic = try JSONSerialization.jsonObject(with: jsonData, options: []) as! Dictionary<String, Any>

//      let input = InputStream(fileAtPath: path)!
//      input.open()
//      let dic = try JSONSerialization.jsonObject(with: input, options: []) as! Dictionary<String, Any>
      
      loadFigureViews(vc, dic["figureView"] as! Dictionary<String, Any>)
      
    } catch let err {
      print(err)
    }
  }
  
  private func loadFigureViews(_ vc: ViewController, _ dic: Dictionary<String, Any>) {
    
    let fvArr = dic["figureView"] as! Array<Dictionary<String, Any>>
    for fvDic in fvArr {
      vc.addFigureView(figureView: FigureView.fromDictionary(fvDic, vc))
    }
    
  }
}
