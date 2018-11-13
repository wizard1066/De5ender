//
//  BuildComponent.swift
//  SKDefender
//
//  Created by localadmin on 13.11.18.
//  Copyright © 2018 ch.cqd.skdefender. All rights reserved.
//

import SpriteKit
import GameplayKit

class BuildComponent: GKComponent {
    let node: EntityNode
    
    init(entity: GKEntity, texture: SKTexture, size: CGSize) {
        node = EntityNode(texture: texture, color: SKColor.white, size: size)
        node.entity = entity
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // HUD function
    func changeTexture(imageNamed: String) {
        node.texture = SKTexture(imageNamed: imageNamed)
    }
}

