//
//  MutantComponent.swift
//  SKDefender
//
//  Created by localadmin on 22.11.18.
//  Copyright © 2018 ch.cqd.skdefender. All rights reserved.
//

import SpriteKit
import GameplayKit

class MutantComponent: GKComponent {
    let spriteComponent: SpriteComponent
    
    var playableStart: CGFloat = 0
    var playableRegion: CGFloat = UIScreen.main.bounds.maxY * 2
    var localBounds: CGRect!
    var localView: EntityNode!
    var localScan:[EntityNode] = []
    var localForeground:[EntityNode] = []
    var spriteShadow: EntityNode?
    var mines:[BombEntity] = []
    
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
    
    public func returnBomberPosition() -> CGPoint {
        return spriteComponent.node.position
    }
    
    public func setScreen(entity: EntityNode) {
        localView = entity
    }
    
    func beginBombing(loop: Int, skew: Int) {
        let mine = BombEntity(imageName: "mine", owningNode: self.spriteComponent.node)
        //        mine.spriteComponent.node.zPosition = Layer.alien.rawValue
        let path = CGMutablePath()
        let point1 = spriteComponent.node.convert(spriteComponent.node.position, to: playerToKill.spriteComponent.node)
        
//        mine.spriteComponent.node.position = spriteComponent.node.position
        
        path.move(to: spriteComponent.node.position)
        var pathToExecute = playerToKill.spriteComponent.node.position
        if skew % 2 == 0 {
            pathToExecute.x += CGFloat(skew)
            pathToExecute.y += CGFloat(skew)
        } else {
            pathToExecute.x -= CGFloat(skew)
            pathToExecute.y -= CGFloat(skew)
        }
        path.addLine(to: pathToExecute)
        let followLine = SKAction.follow(path, speed: 128)
        print("playerToKill \(spriteComponent.node.position) \(point1) \(playerToKill.spriteComponent.node.position)")
        
        localForeground[foreGroundIndex].addChild(mine.spriteComponent.node)
        
        mine.spriteComponent.node.run(followLine)
        
        self.mines.append(mine)
    }
    
    var runOnce = true
    var scanNodeIndex = 0
    var foreGroundIndex = 0
    var toggle = true
    var playerToKill: PlayerEntity!
    
    override func update(deltaTime seconds: TimeInterval) {
        if runOnce {
            spriteShadow = (self.spriteComponent.node.userData?.object(forKey: "shadow") as? EntityNode)!
            spriteShadow?.alpha = 0.5
            playerToKill = (self.spriteComponent.node.userData?.object(forKey: "player") as? PlayerEntity)!
            runOnce = false
            
//            beginBombing(loop: 0, bomber: spriteComponent.node)
        }
        
        if toggle {
//            beginBombing(loop: 0, bomber: spriteComponent.node)
            toggle = false
            let rand = GKRandomSource.sharedRandom().nextInt(upperBound: 2)
            let pause = SKAction.wait(forDuration: TimeInterval(rand))
            let bomb = SKAction.run {
                let rand = GKRandomSource.sharedRandom().nextInt(upperBound: 8)
                if rand == 4 {
                    self.beginBombing(loop: 0, skew: rand)
                }
            }
            let move = SKAction.run {
                self.toggle = true
                let randX = CGFloat(GKRandomSource.sharedRandom().nextInt(upperBound: 8))
                let randY = CGFloat(GKRandomSource.sharedRandom().nextInt(upperBound: 8))
                if self.playerToKill.spriteComponent.node.position.x < self.spriteComponent.node.position.x {
                    self.spriteComponent.node.position.x -= 10 + randX
                }
                if self.playerToKill.spriteComponent.node.position.x > self.spriteComponent.node.position.x {
                    self.spriteComponent.node.position.x += 10 - randY
                }
                if self.playerToKill.spriteComponent.node.position.y < self.spriteComponent.node.position.y {
                    self.spriteComponent.node.position.y -= 10 + randX
                }
                if self.playerToKill.spriteComponent.node.position.y > self.spriteComponent.node.position.y {
                    self.spriteComponent.node.position.y += 10 - randY
                }
            }
//            let amountToRotate:CGFloat = 0.5
//            let rotateClockwise = SKAction.rotate(byAngle: amountToRotate.degreesToRadians(), duration: 0.2)
            spriteComponent.node.run(SKAction.sequence([pause,move,bomb]))
        }
        
        for mine in mines {
            mine.update(deltaTime: seconds)
        }
        
//        spriteComponent.node.position.x -= 2
//        spriteShadow?.position.x -= 2
        
        if spriteComponent.node.parent == nil {
            spriteShadow?.removeFromParent()
        }
        
//        if spriteComponent.node.position.x < 0 {
//            if spriteComponent.node.parent != nil {
//                spriteComponent.node.removeFromParent()
//                foreGroundIndex -= 1
//                if foreGroundIndex < 0 {
//                    foreGroundIndex = 7
//                }
//            }
//            spriteComponent.node.position.x = 2048
//            localForeground[foreGroundIndex].addChild(spriteComponent.node)
//        }
        
//        if spriteShadow!.position.x < 0 {
//            if spriteShadow?.parent != nil {
//                spriteShadow?.removeFromParent()
//                scanNodeIndex -= 1
//                if scanNodeIndex < 0 {
//                    scanNodeIndex = 7
//                }
//            }
//            spriteShadow?.position.x = 2048
//            localForeground[scanNodeIndex].addChild(spriteShadow!)
//        }
        
        
//        if spriteComponent.node.position.x > 2048 {
//            if spriteComponent.node.parent != nil {
//                spriteComponent.node.removeFromParent()
//                foreGroundIndex += 1
//                if foreGroundIndex == 8 {
//                    foreGroundIndex = 0
//                }
//                spriteComponent.node.position.x = 0
//                localForeground[foreGroundIndex].addChild(spriteComponent.node)
//            }
//        }
        
//        if spriteShadow!.position.x > 2048 {
//            if spriteComponent.node.parent != nil {
//                spriteShadow?.removeFromParent()
//                scanNodeIndex += 1
//                if scanNodeIndex == 8 {
//                    scanNodeIndex = 0
//                }
//                spriteShadow?.position.x = 0
//                localScan[scanNodeIndex].addChild(spriteShadow!)
//            }
//        }
        
    }
    
}

