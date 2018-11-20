//
//  BomberComponent.swift
//  SKDefender
//
//  Created by localadmin on 19.11.18.
//  Copyright © 2018 ch.cqd.skdefender. All rights reserved.
//

import SpriteKit
import GameplayKit

class BomberComponent: GKComponent {
    let spriteComponent: SpriteComponent
    
    var playableStart: CGFloat = 0
    var playableRegion: CGFloat = UIScreen.main.bounds.maxY * 2
    var localBounds: CGRect!
    var localView: EntityNode!
    var localScan:[EntityNode] = []
    var localForeground:[EntityNode] = []
    var spriteShadow: EntityNode?
    
    init(entity: GKEntity, screenBounds: CGRect, view2D: EntityNode, scanNodes: [EntityNode], foregrounds: [EntityNode], shadow:EntityNode?) {
        localBounds = screenBounds
        localView = view2D
        localScan = scanNodes
        localForeground = foregrounds
        self.spriteComponent = entity.component(ofType: SpriteComponent.self)!
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func sayHello() {
        print("HelloWorld")
    }
    
    public func returnAlienPosition() -> CGPoint {
        return spriteComponent.node.position
    }
    
    public func dropMines() {
        let mineAction = SKAction.run {
            let mine = PlayerEntity(imageName: "mine")
            let mineNode = mine.spriteComponent.node
            mineNode.size = CGSize(width: 64, height: 64)
            mineNode.position = self.spriteComponent.node.position
            mineNode.physicsBody = SKPhysicsBody.init(circleOfRadius: self.spriteComponent.node.size.width/10 + 8)
            mineNode.physicsBody?.affectedByGravity = false
//            mineNode.zPosition = Layer.mine.rawValue
            mineNode.name = "mine"
            //        playerNode.size = CGSize(width: playerNode.size.width/4, height: playerNode.size.height/4)
//            mineNode.delegate = localView
            self.localView.addChild(mineNode)
        }
        let waitAction = SKAction.run {
            let pause = GKRandomSource.sharedRandom().nextInt(upperBound: 8)
            SKAction.wait(forDuration: TimeInterval(pause))
        }
        let waitAction2 = SKAction.wait(forDuration: 4)
        
        spriteComponent.node.run(SKAction.sequence([waitAction2, mineAction]))
    }
    
    var runOnce = true
    var scanNodeIndex = 0
    var foreGroundIndex = 0
    
    override func update(deltaTime seconds: TimeInterval) {
        if runOnce {
//            dropMines()
            spriteShadow = (self.spriteComponent.node.userData?.object(forKey: "shadow") as? EntityNode)!
            spriteShadow?.alpha = 0.2
            runOnce = false
        }

        spriteComponent.node.position.x += 2
        spriteShadow?.position.x += 2
        
//        spriteComponent.node.alpha = 0.2
        
        if spriteComponent.node.position.x > 2048 {
            spriteComponent.node.removeFromParent()
            foreGroundIndex += 1
            if foreGroundIndex == 4 {
                foreGroundIndex = 0
            }
            spriteComponent.node.position.x = 0
            localForeground[foreGroundIndex].addChild(spriteComponent.node)
        }
        
        if spriteShadow!.position.x > 2048 {
            spriteShadow?.removeFromParent()
            scanNodeIndex += 1
            if scanNodeIndex == 4 {
                scanNodeIndex = 0
            }
            spriteShadow?.position.x = 0
            localScan[scanNodeIndex].addChild(spriteShadow!)
        }
        
    }
    
  
    
}
