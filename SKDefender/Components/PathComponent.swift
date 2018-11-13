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
    
    var screenWidth = UIScreen.main.bounds.maxY * 2
    
    init(entity: GKEntity) {
        self.shapeComponent = entity.component(ofType: ShapeComponent.self)!
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func releaseFireLeft(_ lastUpdateTime: TimeInterval) {
        let amountToMove = screenWidth * 0.80
        let path2F = SKAction.move(by: CGVector(dx: -amountToMove, dy: 0), duration: 1)
        let removeM = SKAction.removeFromParent()
        self.shapeComponent.node.run(SKAction.sequence([path2F,removeM]))
    }
    
    func releaseFireRight(_ lastUpdateTime: TimeInterval) {
        let amountToMove = screenWidth * 0.80
        let path2F = SKAction.move(by: CGVector(dx: amountToMove, dy: 0), duration: 1)
        let removeM = SKAction.removeFromParent()
        self.shapeComponent.node.run(SKAction.sequence([path2F,removeM]))
    }
}
