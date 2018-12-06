//
//  MutantEntity.swift
//  SKDefender
//
//  Created by localadmin on 26.11.18.
//  Copyright © 2018 ch.cqd.skdefender. All rights reserved.
//

import SpriteKit
import GameKit

class MutantEntity: GKEntity {
    var spriteComponent: SpriteComponent!
    var mutantComponent: MutantComponent!
    //    var bomb: SKSpriteNode!
    
    init(imageName: String, xCord: CGFloat, yCord: CGFloat, screenBounds: CGRect, view2D: EntityNode, scanNodes: [EntityNode], foregrounds: [EntityNode], shadowNode: EntityNode?, playerToKill: PlayerEntity?) {
        //    init(imageName: String) {
        super.init()
        
        let texture = SKTexture(imageNamed: imageName)
        spriteComponent = SpriteComponent(entity: self, texture: texture, size: texture.size())
        addComponent(spriteComponent)
        
        mutantComponent = MutantComponent(entity: self, screenBounds: screenBounds, view2D: view2D, scanNodes: scanNodes, foregrounds: foregrounds, shadow: shadowNode)
        addComponent(mutantComponent)
        
        //        bomb = SKSpriteNode(imageNamed: "mine")
        //        bomb.size = CGSize(width: 64, height: 64)
        
        
        let spriteNode = spriteComponent.node
        spriteNode.size = CGSize(width: spriteNode.size.width/2, height: spriteNode.size.height/2)
        spriteNode.position = CGPoint(x: xCord, y: yCord)
        if shadowNode != nil {
//            spriteNode.physicsBody = SKPhysicsBody.init(texture: texture, size: spriteNode.size)
            spriteNode.physicsBody = SKPhysicsBody.init(circleOfRadius: spriteNode.size.width/5 )
            spriteNode.physicsBody?.categoryBitMask = PhysicsCat.Alien
            spriteNode.physicsBody?.collisionBitMask = PhysicsCat.None
            spriteNode.physicsBody?.contactTestBitMask = PhysicsCat.Fire | PhysicsCat.Player
            spriteNode.physicsBody?.affectedByGravity = false
        }
        spriteNode.name = "mutant"
        
        if shadowNode != nil {
            spriteNode.userData = NSMutableDictionary()
            spriteNode.userData?.setObject(shadowNode, forKey: "shadow" as NSCopying)
            spriteNode.userData?.setObject(self, forKey: "class" as NSCopying)
        }
        
        if playerToKill != nil {
            spriteNode.userData?.setObject(playerToKill, forKey: "player" as NSCopying)
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

