//
//  PathComponent.swift
//  SKDefender
//
//  Created by localadmin on 08.11.18.
//  Copyright © 2018 ch.cqd.skdefender. All rights reserved.
//

import SpriteKit
import GameplayKit

class PathComponent: GKComponent {
    let shapeComponent: ShapeComponent
    
    let impulse: CGFloat = 800
    var engage: CGFloat = 0
    var velocity = CGPoint.zero
    
    var playableStart: CGFloat = 0
    
    init(entity: GKEntity) {
        self.shapeComponent = entity.component(ofType: ShapeComponent.self)!
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func releaseFireLeft(_ lastUpdateTime: TimeInterval) {
        engage = -impulse
    }
    
    func releaseFireRight(_ lastUpdateTime: TimeInterval) {
        engage = impulse
    }
    
    func applyMovement(_ seconds: TimeInterval) {
        
        let spriteNode = shapeComponent.node
        
        let velocityVStep = engage * CGFloat(seconds)
        spriteNode.position.x = spriteNode.position.x + velocityVStep
        if spriteNode.position.x > 1600 || spriteNode.position.x < -1600 {
            spriteNode.run(SKAction.removeFromParent())
            engage = 0
        }
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        applyMovement(seconds)
    }
}
