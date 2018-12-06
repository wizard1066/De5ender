//
//  textComponent.swift
//  SKDefender
//
//  Created by localadmin on 30.11.18.
//  Copyright © 2018 ch.cqd.skdefender. All rights reserved.
//

import SpriteKit
import GameplayKit

class TextComponent: GKComponent {
    let node: SKLabelNode
    
    init(entity: GKEntity, text2D: String) {
        node = SKLabelNode(text: text2D)
        node.entity = entity
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func returnNodePosition() -> CGPoint {
        return node.position
    }
    
    func moreScore(score: Int) {
        let oldScore = Int(node.text!)
        let newScore = oldScore! + score
        node.text = "\(newScore)"
    }
    
    func lessScore(score: Int) {
        let oldScore = Int(node.text!)
        let newScore = oldScore! - score
        node.text = "\(newScore)"
    }
    
    
    
}
