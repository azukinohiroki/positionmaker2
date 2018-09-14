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
import RealmSwift

//class Figure: NSManagedObject {
class Figure: Object {

  @objc dynamic var id: NSNumber = 0
  @objc dynamic var name: String = ""
  @objc dynamic var group: NSNumber = 0
  @objc dynamic var color: NSNumber = 0
  @objc dynamic var direction: NSNumber = 0
  @objc dynamic var height: NSNumber = 0
  
  static let Red:   NSNumber = 0xFF0000
  static let Green: NSNumber = 0x00FF00
  static let Blue:  NSNumber = 0x0000FF
  static let Cyan:  NSNumber = 0x00FFFF

  static func defaultFigure() -> Figure {
    
//    let appDelegate          = UIApplication.shared.delegate as! AppDelegate
//    let managedObjectContext = appDelegate.coreDataHelper.managedObjectContext!
//    let entity = NSEntityDescription.entity(forEntityName: "Figure", in: managedObjectContext)!
    
//    let f = Figure(entity: entity, insertInto: managedObjectContext)
    
//    let realm = try! Realm()
    
    let f = Figure()
    f.color = Cyan
    f.name  = ""
//    f.id = NSNumber(value: (realm.objects(Figure.self).sorted(byKeyPath: "id", ascending: false).first?.id ?? 0).intValue + 1)
    
//    try! realm.write {
//      realm.add(f)
//    }
    
    return f
  }
  
  private func createNewId() -> Int {
    let realm = try! Realm()
    return (realm.objects(type(of: self).self).sorted(byKeyPath: "id", ascending: false).first?.id ?? 0).intValue + 1
  }
  
  override static func primaryKey() -> String? {
    return "id"
  }
}
