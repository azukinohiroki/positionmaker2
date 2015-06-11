//
//  Figure.swift
//  positionmaker2
//
//  Created by Hiroki Taoka on 2015/06/10.
//  Copyright (c) 2015年 azukinohiroki. All rights reserved.
//

import Foundation
import CoreData

class Figure: NSManagedObject {
  
  @NSManaged var id: NSNumber
  @NSManaged var name: String
  @NSManaged var group: NSNumber
  @NSManaged var color: NSNumber
  @NSManaged var direction: NSDecimalNumber
  @NSManaged var height: NSNumber
  
  enum FigureColor: Int32 {
    case Blue  = 0x0000FF
    case Red   = 0xFF0000
    case Green = 0x00FF00
  }
}