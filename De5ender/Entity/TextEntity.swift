//
//  TextEntity.swift
//  SKDefender
//
//  Created by localadmin on 30.11.18.
//  Copyright © 2018 ch.cqd.skdefender. All rights reserved.
//

import SpriteKit
import GameplayKit

class TextEntity: GKEntity {
    var textComponent: TextComponent!
    
    init(text: String, Cords: CGPoint, name: String) {
        super.init()
        
        textComponent = TextComponent(entity: self, text2D: text)
        addComponent(textComponent)
        
        let spriteNode = textComponent.node
        spriteNode.name = name
        spriteNode.position = Cords
        spriteNode.color = UIColor.white
        spriteNode.fontName = "Futura-CondensedMedium"
        spriteNode.fontSize = 48
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
