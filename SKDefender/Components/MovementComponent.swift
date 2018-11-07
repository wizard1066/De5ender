//
//  MovementComponent.swift
//  SKDefender
//
//  Created by localadmin on 07.11.18.
//  Copyright © 2018 ch.cqd.skdefender. All rights reserved.
//

import SpriteKit
import GameplayKit

class MovementComponent: GKComponent {
    let spriteComponent: SpriteComponent
    
    let impulse: CGFloat = 400
    let ompulse: CGFloat = -400
    var velocity = CGPoint.zero
    let gravity: CGFloat = -1500
    
    var playableStart: CGFloat = 0
    
  

    init(entity: GKEntity) {
        self.spriteComponent = entity.component(ofType: SpriteComponent.self)!
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func applyImpulse(_ lastUpdateTime: TimeInterval) {
        velocity = CGPoint(x: 0, y: impulse)
    }
    
    func applyOmpulse(_ lastUpdateTime: TimeInterval) {
        velocity = CGPoint(x: 0, y: ompulse)
    }
    
    func applyZero(_ lastUpdateTime: TimeInterval) {
        velocity = CGPoint(x: 0, y: 0)
    }
    
    func applyMovement(_ seconds: TimeInterval) {
        let spriteNode = spriteComponent.node
        
        // Apply Gravity
//        let gravityStep = gravity * CGFloat(seconds)
//        velocity.y = velocity.y + gravityStep
        
        // Apply Velocity
        
        let velocityStep = velocity.y * CGFloat(seconds)
        spriteNode.position.y = spriteNode.position.y + velocityStep
        
        
        // Temporary Ground Hit
        if spriteNode.position.y - spriteNode.size.height / 2 < playableStart {
            spriteNode.position = CGPoint(x: spriteNode.position.x, y: playableStart + spriteNode.size.height / 2)
        }
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        applyMovement(seconds)
    }
    
//    override func update(deltaTime seconds: TimeInterval) {
//        if (entity as? PlayerEntity) != nil {
//            applyMovement(seconds)
//        }
//    }
    
    
}
