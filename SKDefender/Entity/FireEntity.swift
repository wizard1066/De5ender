//
//  FireEntity.swift
//  SKDefender
//
//  Created by localadmin on 08.11.18.
//  Copyright © 2018 ch.cqd.skdefender. All rights reserved.
//

import SpriteKit
import GameplayKit

class FireEntity: GKEntity {
    
    var shapeComponent: ShapeComponent!
    var pathComponent: PathComponent!
    
    init(rect: CGRect) {
        super.init()
        
        shapeComponent = ShapeComponent(entity: self, rectangle: rect)
        addComponent(shapeComponent)
        
        pathComponent = PathComponent(entity: self)
        addComponent(pathComponent)
    
        
        let shapeNode = shapeComponent.node
        shapeNode.physicsBody = SKPhysicsBody.init(edgeLoopFrom: rect)
        shapeNode.physicsBody?.categoryBitMask = PhysicsCat.Fire
        shapeNode.physicsBody?.collisionBitMask = PhysicsCat.None
        shapeNode.physicsBody?.contactTestBitMask = PhysicsCat.Alien | PhysicsCat.Ground
        shapeNode.physicsBody?.affectedByGravity = false
        shapeNode.name = "missile"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
