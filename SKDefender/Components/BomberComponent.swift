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
    let spriteShadow: SpriteComponent
    
    var playableStart: CGFloat = 0
    var playableRegion: CGFloat = UIScreen.main.bounds.maxY * 2
    var localBounds: CGRect!
    var localView: EntityNode!
    
    init(entity: GKEntity, screenBounds: CGRect, view2D: EntityNode) {
        localBounds = screenBounds
        localView = view2D
        self.spriteShadow = entity.component(ofType: SpriteComponent.self)!
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
    
    override func update(deltaTime seconds: TimeInterval) {
        if runOnce {
//            dropMines()
            runOnce = false
        }

        spriteComponent.node.position.x += 2
        spriteShadow.node.position.x += 8
        
        if spriteComponent.node.position.x > 8192 {
            spriteComponent.node.position.x = 0
        }
        
        // 8 landscapes + 1 = 14336
//        if spriteComponent.node.position.x > 14336 + 2048 {
//            spriteShadow.node.position.x -= 0
//            spriteComponent.node.position.x -= 0
//        }
//        if spriteComponent.node.position.x < -(14336 + 2048) {
//            spriteShadow.node.position.x -= 0
//            spriteComponent.node.position.x -= 0
//        }
    }
    
  
    
}
