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
    
    let impulse: CGFloat = 256
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
    
    func applyImpulseX(_ lastUpdateTime: TimeInterval) {
        let spriteNode = spriteComponent.node
        let amountToMove = UIScreen.main.bounds.maxX / 10
        if spriteNode.userData?.object(forKey: "direction") as? String == "right" {
            let advanceAction = SKAction.move(by: CGVector(dx: amountToMove, dy: 0), duration: 0.4)
            let fallBackAction = SKAction.move(by: CGVector(dx: -amountToMove, dy: 0), duration: 1)
            spriteNode.run(SKAction.sequence([advanceAction,fallBackAction]))
//            velocity.y += 256
        }
        if spriteNode.userData?.object(forKey: "direction") as? String == "left" {
            let advanceAction = SKAction.move(by: CGVector(dx: -amountToMove, dy: 0), duration: 0.4)
            let fallBackAction = SKAction.move(by: CGVector(dx: amountToMove, dy: 0), duration: 1)
            spriteNode.run(SKAction.sequence([advanceAction,fallBackAction]))
//            velocity.y -= 256
        }
        
    }
    
    func applyImpulseLeft(_ lastUpdateTime: TimeInterval) {
        print("applyImpulseRight right")
        let spriteNode = spriteComponent.node
        spriteNode.userData?.setObject("right", forKey: "direction" as NSCopying)
        spriteNode.texture = SKTexture(imageNamed: "starship")
       
        let amountToMove = UIScreen.main.bounds.maxX
        print("amountToMove \(amountToMove)")
        spriteNode.run(SKAction.move(by: CGVector(dx: -amountToMove, dy: 0), duration: 2))
        velocity = CGPoint(x: impulse, y: 0)
    }

    func applyImpulseRight(_ lastUpdateTime: TimeInterval) {
        print("applyImpulseRight left")
        let spriteNode = spriteComponent.node
        spriteNode.userData?.setObject("left", forKey: "direction" as NSCopying)
        spriteNode.texture = SKTexture(imageNamed: "shipstar")
       
        let amountToMove = UIScreen.main.bounds.maxX
        spriteNode.run(SKAction.move(by: CGVector(dx: amountToMove, dy: 0), duration: 2))
        velocity = CGPoint(x: impulse, y: 0)
    }
    
    func leftTexture() {
        let spriteNode = spriteComponent.node
        spriteNode.texture = SKTexture(imageNamed: "starship")
    }
    
    func rightTexture() {
        let spriteNode = spriteComponent.node
        spriteNode.texture = SKTexture(imageNamed: "shipstar")
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
        
        if velocity.y < 0 {
            velocity.y = velocity.y + 1
        }
        if velocity.y > 0 {
            velocity.y = velocity.y - 1
        }
        
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
