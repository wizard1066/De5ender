//
//  BombEntity.swift
//  SKDefender
//
//  Created by localadmin on 22.11.18.
//  Copyright © 2018 ch.cqd.skdefender. All rights reserved.
//

import SpriteKit
import GameplayKit

class BombEntity: GKEntity {
    var spriteComponent: SpriteComponent!
    var mineComponent: MineComponent!
    
    init(imageName: String, owningNode: EntityNode) {
        super.init()
        
        let texture = SKTexture(imageNamed: imageName)
        spriteComponent = SpriteComponent(entity: self, texture: texture, size: texture.size())
        addComponent(spriteComponent)
        
        mineComponent = MineComponent(entity: self)
        addComponent(mineComponent)
        
        let mineNode = spriteComponent.node
        mineNode.size = CGSize(width: 32, height: 32)
//        mineNode.position.x = owningNode.position.x
//        mineNode.position.y = owningNode.position.y
        mineNode.physicsBody = SKPhysicsBody.init(circleOfRadius: mineNode.size.width/2)
        mineNode.physicsBody?.affectedByGravity = false
        mineNode.physicsBody?.isDynamic = false
        mineNode.physicsBody?.categoryBitMask = PhysicsCat.Mine
        mineNode.physicsBody?.collisionBitMask = PhysicsCat.None
        mineNode.physicsBody?.contactTestBitMask = PhysicsCat.Player
        //        mineNode.zPosition = Layer.mine.rawValue
        mineNode.name = "mine"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

