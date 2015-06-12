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

let Blue = 0x0000FF

class Figure: NSManagedObject {
  
  @NSManaged var id: NSNumber
  @NSManaged var name: String
  @NSManaged var group: NSNumber
  @NSManaged var color: NSNumber
  @NSManaged var direction: NSDecimalNumber
  @NSManaged var height: NSNumber
  
  static let Red   :NSNumber = 0xFF0000
  static var Green :NSNumber = 0x00FF00

  static func defaultFigure() -> Figure {
    
    var appDelegate          = UIApplication.sharedApplication().delegate as! AppDelegate
    var managedObjectContext = appDelegate.coreDataHelper.managedObjectContext!;
    var entity = NSEntityDescription.entityForName("Figure", inManagedObjectContext: managedObjectContext)!
    
    var f = Figure(entity: entity, insertIntoManagedObjectContext: managedObjectContext)
    f.color = NSNumber(int: 0x0000FF)
    f.name  = ""
    
    return f
  }
}