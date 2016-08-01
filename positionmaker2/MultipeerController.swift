//
//  MultipeerController.swift
//  positionmaker2
//
//  Created by Hiroki Taoka on 2016/08/01.
//  Copyright © 2016年 azukinohiroki. All rights reserved.
//

import Foundation
import MultipeerConnectivity

class MultipeerController {
  
  func initialize() {
    var peerID  = MCPeerID(displayName: UIDevice.currentDevice().name)
    var session = MCSession(peer: peerID)
//    session.delegate = self
  }
}