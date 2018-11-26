//
//  BaitComponent.swift
//  SKDefender
//
//  Created by localadmin on 26.11.18.
//  Copyright © 2018 ch.cqd.skdefender. All rights reserved.
//

import SpriteKit
import GameplayKit

class BaitComponent: GKComponent {
    let spriteComponent: SpriteComponent
    
    init(entity: GKEntity) {
        self.spriteComponent = entity.component(ofType: SpriteComponent.self)!
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func returnNodePosition() -> CGPoint {
        return spriteComponent.node.position
    }
    
    var lifetime = 0
    
    override func update(deltaTime seconds: TimeInterval) {
        if spriteComponent.node.alpha == 1 {
            spriteComponent.node.run(SKAction.fadeOut(withDuration: 0.25))
        }
        if spriteComponent.node.alpha == 0 {
            spriteComponent.node.run(SKAction.fadeIn(withDuration: 0.25))
            lifetime += 1
        }
        if lifetime == 8 {
            let fadeOut = SKAction.fadeOut(withDuration: 1)
            let fadeAway = SKAction.removeFromParent()
            spriteComponent.node.run(SKAction.sequence([fadeOut, fadeAway]))
            spriteComponent.node.removeFromParent()
        }
    }
    
}

