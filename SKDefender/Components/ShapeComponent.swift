//
//  ShapeComponent.swift
//  SKDefender
//
//  Created by localadmin on 08.11.18.
//  Copyright © 2018 ch.cqd.skdefender. All rights reserved.
//

import SpriteKit
import GameplayKit

class ShapeEntityNode: SKShapeNode {
    
}

class ShapeComponent: GKComponent {
    let node: ShapeEntityNode
    
    init(entity: GKEntity, rectangle: CGRect) {
        node = ShapeEntityNode(rect: rectangle)
        node.fillColor = UIColor.red
        node.entity = entity
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
