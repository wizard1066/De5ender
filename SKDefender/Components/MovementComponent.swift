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
    var velocity = CGPoint.zero
    let gravity: CGFloat = -1500
    
    var playableStart: CGFloat = 0
    var playableRegion: CGFloat = UIScreen.main.bounds.maxY * 2
    
  

    init(entity: GKEntity) {
        self.spriteComponent = entity.component(ofType: SpriteComponent.self)!
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func applyImpulseUp(_ lastUpdateTime: TimeInterval) {
        velocity = CGPoint(x: 0, y: impulse)
    }
    
    func applyImpulseDown(_ lastUpdateTime: TimeInterval) {
        velocity = CGPoint(x: 0, y: -impulse)
    }
    
    func applyImpulseLeft(_ lastUpdateTime: TimeInterval) {
        print("applyImpulseRight right")
        let spriteNode = spriteComponent.node
        spriteNode.userData?.setObject("right", forKey: "direction" as NSCopying)
        spriteNode.zRotation = CGFloat(0).degreesToRadians()
        spriteNode.run(SKAction.move(by: CGVector(dx: -1024, dy: 0), duration: 2))
        velocity = CGPoint(x: -impulse, y: 0)
    }

    func applyImpulseRight(_ lastUpdateTime: TimeInterval) {
        print("applyImpulseRight left")
        let spriteNode = spriteComponent.node
        spriteNode.userData?.setObject("left", forKey: "direction" as NSCopying)
//        spriteNode.zRotation = CGFloat(180).degreesToRadians()
        spriteNode.run(SKAction.move(by: CGVector(dx: 1024, dy: 0), duration: 2))
        velocity = CGPoint(x: impulse, y: 0)
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
        
        let velocityVStep = velocity.y * CGFloat(seconds)
        spriteNode.position.y = spriteNode.position.y + velocityVStep
        
//        let velocityHStep = velocity.x * CGFloat(seconds)
//        spriteNode.position.x = spriteNode.position.x + velocityHStep
        
        
        // Temporary Ground Hit
        if spriteNode.position.y - spriteNode.size.height / 2 < playableStart {
            spriteNode.position = CGPoint(x: spriteNode.position.x, y: playableStart + spriteNode.size.height / 2)
        }
        if spriteNode.position.y + spriteNode.size.height / 2 > playableRegion {
            spriteNode.position = CGPoint(x: spriteNode.position.x, y: playableRegion - spriteNode.size.height / 2)
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
