//
//  MineComponent.swift
//  SKDefender
//
//  Created by localadmin on 22.11.18.
//  Copyright © 2018 ch.cqd.skdefender. All rights reserved.
//

import SpriteKit
import GameplayKit

class MineComponent: GKComponent {
    let spriteComponent: SpriteComponent
    var localDirection: spriteAttack!
    
    init(entity: GKEntity, direct: spriteAttack) {
        self.spriteComponent = entity.component(ofType: SpriteComponent.self)!
        localDirection = direct
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func returnNodePosition() -> CGPoint {
        return spriteComponent.node.position
    }
    
    public func setDirect(direct: spriteAttack) {
        localDirection = direct
    }
    
    var lifetime = 0
    
    override func update(deltaTime seconds: TimeInterval) {
        if spriteComponent.node.parent == nil {
            return
        }
        if localDirection == .cominEast {
            spriteComponent.node.position.x += 1
        } else {
            spriteComponent.node.position.x -= 1
        }
        
        if spriteComponent.node.alpha == 1 {
            spriteComponent.node.run(SKAction.fadeOut(withDuration: 0.5))
        }
        if spriteComponent.node.alpha == 0 {
            spriteComponent.node.run(SKAction.fadeIn(withDuration: 0.5))
            lifetime += 1
        }
        if lifetime == 8 {
            let fadeOut = SKAction.fadeOut(withDuration: 1)
            let fadeAway = SKAction.removeFromParent()
            spriteComponent.node.run(SKAction.sequence([fadeOut, fadeAway]))
        }
    }
    
}
