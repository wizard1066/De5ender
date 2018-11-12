//
//  AlienEntity.swift
//  SKDefender
//
//  Created by localadmin on 12.11.18.
//  Copyright © 2018 ch.cqd.skdefender. All rights reserved.
//

import SpriteKit
import GameKit

class AlienEntity: GKEntity {
    var spriteComponent: SpriteComponent!
    var alienComponent: AlienDecentComponent!
    
    init(imageName: String) {
        super.init()
        
        let texture = SKTexture(imageNamed: imageName)
        spriteComponent = SpriteComponent(entity: self, texture: texture, size: texture.size())
        addComponent(spriteComponent)
        
        alienComponent = AlienDecentComponent(entity: self)
        addComponent(alienComponent)
        
        let spriteNode = spriteComponent.node
        spriteNode.size = CGSize(width: spriteNode.size.width/2, height: spriteNode.size.height/2)
        spriteNode.physicsBody = SKPhysicsBody.init(texture: texture, size: spriteNode.size)
        spriteNode.physicsBody?.categoryBitMask = PhysicsCat.Alien
        spriteNode.physicsBody?.collisionBitMask = PhysicsCat.None
        spriteNode.physicsBody?.contactTestBitMask = PhysicsCat.SpaceMan | PhysicsCat.Fire
        spriteNode.name = "alien"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

