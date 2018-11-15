//
//  HeadsUpEntity.swift
//  SKDefender
//
//  Created by localadmin on 13.11.18.
//  Copyright © 2018 ch.cqd.skdefender. All rights reserved.
//

import SpriteKit
import GameplayKit

class HeadsUpEntity: GKEntity {
    var hudComponent: BuildComponent!
    
    init(imageName: String, xCord: CGFloat, yCord: CGFloat, name: String) {
        //    init(imageName: String) {
        super.init()
        
        let texture = SKTexture(imageNamed: imageName)
        hudComponent = BuildComponent(entity: self, texture: texture, size: texture.size())
        addComponent(hudComponent)
        
        let spriteNode = hudComponent.node
        spriteNode.name = name
        spriteNode.position = CGPoint(x: xCord, y: yCord)
        spriteNode.size = CGSize(width: 128, height: 128)
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
