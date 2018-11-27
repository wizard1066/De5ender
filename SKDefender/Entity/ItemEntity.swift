//
//  ItemEntity.swift
//  SKDefender
//
//  Created by localadmin on 27.11.18.
//  Copyright © 2018 ch.cqd.skdefender. All rights reserved.
//

import SpriteKit
import GameplayKit

class ItemEntity: GKEntity {
    var itemComponent: ItemComponent!
    
    init(imageName: String, xCord: CGFloat, yCord: CGFloat, shadowNode: EntityNode?) {
        super.init()
        
        let texture = SKTexture(imageNamed: imageName)
        itemComponent = ItemComponent(entity: self, texture: texture, size: texture.size())
        addComponent(itemComponent)
        
        let spriteNode = itemComponent.node
        spriteNode.name = "spaceman"
        spriteNode.position = CGPoint(x: xCord, y: yCord)
        spriteNode.size = CGSize(width: spriteNode.size.width/2, height: spriteNode.size.height/2)
        spriteNode.physicsBody = SKPhysicsBody.init(texture: texture, size: spriteNode.size)
        spriteNode.physicsBody?.categoryBitMask = PhysicsCat.SpaceMan
        spriteNode.physicsBody?.collisionBitMask = PhysicsCat.None
        spriteNode.physicsBody?.contactTestBitMask = PhysicsCat.Ground | PhysicsCat.Player | PhysicsCat.Fire
        spriteNode.physicsBody?.affectedByGravity = true
        spriteNode.physicsBody?.isDynamic = false
        
        if shadowNode != nil {
            spriteNode.userData = NSMutableDictionary()
            spriteNode.userData?.setObject(shadowNode, forKey: "shadow" as NSCopying)
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
