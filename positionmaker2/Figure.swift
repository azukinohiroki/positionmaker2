//
//  Figure.swift
//  positionmaker2
//
//  Created by Hiroki Taoka on 2015/06/10.
//  Copyright (c) 2015年 azukinohiroki. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class Figure: NSManagedObject {
  
  @NSManaged var id: NSNumber
  @NSManaged var name: String
  @NSManaged var group: NSNumber
  @NSManaged var color: NSNumber
  @NSManaged var direction: NSDecimalNumber
  @NSManaged var height: NSNumber
  
  static let Red:   NSNumber = 0xFF0000
  static let Green: NSNumber = 0x00FF00
  static let Blue:  NSNumber = 0x0000FF

  static func defaultFigure() -> Figure {
    
    let appDelegate          = UIApplication.sharedApplication().delegate as! AppDelegate
    let managedObjectContext = appDelegate.coreDataHelper.managedObjectContext!
    let entity = NSEntityDescription.entityForName("Figure", inManagedObjectContext: managedObjectContext)!
    
    let f = Figure(entity: entity, insertIntoManagedObjectContext: managedObjectContext)
    f.color = Blue
    f.name  = ""
    
    return f
  }
}