//
//  ItemComponent.swift
//  SKDefender
//
//  Created by localadmin on 27.11.18.
//  Copyright © 2018 ch.cqd.skdefender. All rights reserved.
//

import SpriteKit
import GameplayKit

class ItemComponent: GKComponent {
    let node: EntityNode
    
    init(entity: GKEntity, texture: SKTexture, size: CGSize) {
        node = EntityNode(texture: texture, color: SKColor.white, size: size)
        node.entity = entity
        node.userData = NSMutableDictionary()
        node.userData?.setObject(status.untouched, forKey: "status" as NSCopying)
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func returnNodePosition() -> CGPoint {
        return node.position
    }
    
}
