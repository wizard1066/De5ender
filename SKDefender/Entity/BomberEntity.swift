//
//  BomberEntity.swift
//  SKDefender
//
//  Created by localadmin on 19.11.18.
//  Copyright © 2018 ch.cqd.skdefender. All rights reserved.
//

import SpriteKit
import GameKit

class BomberEntity: GKEntity {
    var spriteComponent: SpriteComponent!
    var shadowComponent: SpriteComponent!
    var bomberComponent: BomberComponent!
    
    init(imageName: String, xCord: CGFloat, yCord: CGFloat, screenBounds: CGRect, view2D: EntityNode) {
        //    init(imageName: String) {
        super.init()
        
        let texture = SKTexture(imageNamed: imageName)
        spriteComponent = SpriteComponent(entity: self, texture: texture, size: texture.size())
        addComponent(spriteComponent)
        
        shadowComponent = SpriteComponent(entity: self, texture: texture, size: texture.size())
        addComponent(shadowComponent)
        
        bomberComponent = BomberComponent(entity: self, screenBounds: screenBounds, view2D: view2D)
        addComponent(bomberComponent)
        
        let spriteNode = spriteComponent.node
        spriteNode.size = CGSize(width: spriteNode.size.width/2, height: spriteNode.size.height/2)
        spriteNode.physicsBody = SKPhysicsBody.init(texture: texture, size: spriteNode.size)
        spriteNode.position = CGPoint(x: xCord, y: yCord)
        //        spriteNode.physicsBody = SKPhysicsBody.init(circleOfRadius: spriteNode.size.width/2)
        spriteNode.physicsBody?.categoryBitMask = PhysicsCat.Alien
        spriteNode.physicsBody?.collisionBitMask = PhysicsCat.None
        spriteNode.physicsBody?.contactTestBitMask = PhysicsCat.SpaceMan | PhysicsCat.Fire
        spriteNode.physicsBody?.affectedByGravity = false
        spriteNode.name = "bomber"
        
        let shadowNode = shadowComponent.node
        shadowNode.size = CGSize(width: spriteNode.size.width/2, height: spriteNode.size.height/2)
        shadowNode.physicsBody = SKPhysicsBody.init(texture: texture, size: spriteNode.size)
        shadowNode.position = CGPoint(x: xCord, y: yCord)
        //        spriteNode.physicsBody = SKPhysicsBody.init(circleOfRadius: spriteNode.size.width/2)
        shadowNode.physicsBody?.categoryBitMask = PhysicsCat.Alien
        shadowNode.physicsBody?.collisionBitMask = PhysicsCat.None
        shadowNode.physicsBody?.contactTestBitMask = PhysicsCat.SpaceMan | PhysicsCat.Fire
        shadowNode.physicsBody?.affectedByGravity = false
        shadowNode.name = "shadow"
        
        spriteNode.userData = NSMutableDictionary()
        spriteNode.userData?.setObject(shadowNode, forKey: "shadow" as NSCopying)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


