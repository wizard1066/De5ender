//
//  GroundEntity.swift
//  SKDefender
//
//  Created by localadmin on 13.11.18.
//  Copyright © 2018 ch.cqd.skdefender. All rights reserved.
//

import SpriteKit
import GameKit

class BuildEntity: GKEntity {
    var spriteComponent: SpriteComponent!
    var buildComponent: BuildComponent!
    
    var playableStart: CGFloat = 0
    var playableRegion: CGFloat = UIScreen.main.bounds.maxY * 2
    var screenWidth = UIScreen.main.bounds.maxY * 2
    
    init(texture: SKTexture, path: CGMutablePath, i: Int) {
        super.init()
        
//        buildComponent = BuildComponent(entity: self)
        buildComponent = BuildComponent(entity: self, texture: texture, size: texture.size())
        addComponent(buildComponent)
        
//        spriteComponent = SpriteComponent(entity: self, texture: texture, size: texture.size())
//        addComponent(spriteComponent)
        
        let spriteNode = buildComponent.node
        spriteNode.anchorPoint = CGPoint(x: 0.0, y: -1.33)
        let texSize = texture.size()
        spriteNode.position = CGPoint(x: CGFloat(i) * texSize.width, y: playableStart)
        spriteNode.name = "foreground"
        
        spriteNode.physicsBody = SKPhysicsBody(edgeChainFrom: path)
        spriteNode.physicsBody?.categoryBitMask = PhysicsCat.Ground
        spriteNode.physicsBody?.collisionBitMask = 0
        spriteNode.physicsBody?.contactTestBitMask = PhysicsCat.Player
        spriteNode.physicsBody?.affectedByGravity = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
