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
  
  func startSave(figureViews: [FigureView]) {
    var fvDic = Array<Dictionary<String, Any>>()
    for fv in figureViews {
      let dic = fv.toDictionary()
      fvDic.append(dic)
    }
    
    do {
      let jsonData = try JSONSerialization.data(withJSONObject: fvDic, options: [])
      let jsonStr  = String(bytes: jsonData, encoding: .utf8)
      print(jsonStr ?? "empty")
      
    } catch let err {
      print(err)
    }
  }
}
