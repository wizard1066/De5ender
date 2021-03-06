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
    var bomberComponent: BomberComponent!
//    var bomb: SKSpriteNode!
    
    init(imageName: String, xCord: CGFloat, yCord: CGFloat, screenBounds: CGRect, view2D: EntityNode, scanNodes: [EntityNode], foregrounds: [EntityNode], shadowNode: EntityNode?) {
        //    init(imageName: String) {
        super.init()
        
        let texture = SKTexture(imageNamed: imageName)
        spriteComponent = SpriteComponent(entity: self, texture: texture, size: texture.size())
        addComponent(spriteComponent)
        
        bomberComponent = BomberComponent(entity: self, screenBounds: screenBounds, view2D: view2D, scanNodes: scanNodes, foregrounds: foregrounds, shadow: shadowNode)
        addComponent(bomberComponent)
        
//        bomb = SKSpriteNode(imageNamed: "mine")
//        bomb.size = CGSize(width: 64, height: 64)
        
        
        let spriteNode = spriteComponent.node
        spriteNode.size = CGSize(width: spriteNode.size.width/2, height: spriteNode.size.height/2)
        spriteNode.position = CGPoint(x: xCord, y: yCord)
        if shadowNode != nil {
            spriteNode.physicsBody = SKPhysicsBody.init(texture: texture, size: spriteNode.size)
            spriteNode.physicsBody?.categoryBitMask = PhysicsCat.Alien
            spriteNode.physicsBody?.collisionBitMask = PhysicsCat.None
            spriteNode.physicsBody?.contactTestBitMask = PhysicsCat.Fire | PhysicsCat.Player
            spriteNode.physicsBody?.affectedByGravity = false
        }
        spriteNode.name = "bomber"
        
        if shadowNode != nil {
            spriteNode.userData = NSMutableDictionary()
            spriteNode.userData?.setObject(shadowNode, forKey: "shadow" as NSCopying)
            spriteNode.userData?.setObject(self, forKey: "class" as NSCopying)
//            spriteNode.userData?.setObject(bomb, forKey: "bomb" as NSCopying)
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


