//
//  PlayerEntity.swift
//  SKDefender
//
//  Created by localadmin on 07.11.18.
//  Copyright © 2018 ch.cqd.skdefender. All rights reserved.
//

import SpriteKit
import GameplayKit

class PlayerEntity: GKEntity {
    var spriteComponent: SpriteComponent!
    var movementComponent: MovementComponent!
    
    init(imageName: String, shadowNode: EntityNode?) {
        super.init()
        
        let texture = SKTexture(imageNamed: imageName)
        spriteComponent = SpriteComponent(entity: self, texture: texture, size: texture.size())
        addComponent(spriteComponent)
        
        movementComponent = MovementComponent(entity: self)
        addComponent(movementComponent)
        
        let spriteNode = spriteComponent.node
//        spriteNode.size = CGSize(width: spriteNode.size.width/2, height: spriteNode.size.height/2)
//        spriteNode.physicsBody = SKPhysicsBody.init(texture: texture, size: spriteNode.size)
        spriteNode.physicsBody = SKPhysicsBody.init(circleOfRadius: spriteNode.size.width/3 + 8)
        spriteNode.physicsBody?.categoryBitMask = PhysicsCat.Player
        spriteNode.physicsBody?.collisionBitMask = PhysicsCat.None
        spriteNode.physicsBody?.contactTestBitMask = PhysicsCat.Ground | PhysicsCat.Mine
        spriteNode.physicsBody?.affectedByGravity = false
        spriteNode.name = "starship"
        
        if shadowNode != nil {
            spriteNode.userData = NSMutableDictionary()
            spriteNode.userData?.setObject(shadowNode, forKey: "shadow" as NSCopying)
            //            spriteNode.userData?.setObject(bomb, forKey: "bomb" as NSCopying)
        }
     }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
