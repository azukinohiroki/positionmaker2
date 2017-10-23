//
//  IconContainerViewController.swift
//  positionmaker2
//
//  Created by Hiroki Taoka on 2017/10/22.
//  Copyright © 2017年 azukinohiroki. All rights reserved.
//

import Foundation
import UIKit

class IconContainerViewController: UIViewController {
  
  var viewController: ViewController!;
  
  override func didMove(toParentViewController parent: UIViewController?) {
    viewController = parent as! ViewController
  }
  
  @IBAction func linesTapped(_ sender: UIButton) {
    viewController.linesTapped(sender)
  }
  
  @IBAction func undoTapped(_ sender: UIButton) {
    viewController.undoTapped(sender)
  }
  
  @IBAction func redoTapped(_ sender: UIButton) {
    viewController.redoTapped(sender)
  }
  
  @IBAction func addTapped(_ sender: UIButton) {
    viewController.addTapped(sender)
  }
  
  @IBAction func saveTapped(_ sender: UIButton) {
    viewController.saveTapped(sender)
  }
  
  @IBAction func playTapped(_ sender: UIButton) {
    viewController.playTapped(sender)
  }
  
  @IBAction func recTapped(_ sender: UIButton) {
    viewController.recTapped(sender)
  }
}
