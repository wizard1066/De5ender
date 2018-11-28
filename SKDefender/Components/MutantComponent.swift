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
    var localForegrounds:[EntityNode] = []
    var spriteShadow: EntityNode?
    var mines:[BombEntity] = []
    
    init(entity: GKEntity, screenBounds: CGRect, view2D: EntityNode, scanNodes: [EntityNode], foregrounds: [EntityNode], shadow:EntityNode?) {
        localBounds = screenBounds
        localView = view2D
        localScan = scanNodes
        localForegrounds = foregrounds
        self.spriteComponent = entity.component(ofType: SpriteComponent.self)!
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setScene(sceneNo: Int) {
        foreGroundIndex = sceneNo
        scanNodeIndex = sceneNo
    }
    
    public func returnMutantPosition() -> CGPoint {
        return spriteComponent.node.position
    }
    
    public func setScreen(entity: EntityNode) {
        localView = entity
    }
    
    public func whereIsPlayer() -> Int {
        var indexToReturn = 0
        for foreground in localForegrounds {
            if playerToKill.spriteComponent.node.position.x < foreground.frame.minX || playerToKill.spriteComponent.node.position.x > foreground.frame.maxX {
                // do nothing
            } else {
                return indexToReturn
            }
            indexToReturn += 1
        }
        return indexToReturn
    }
    
    func beginBombing(loop: Int, skew: Int) {
        
        let mine = BombEntity(imageName: "mine", owningNode: self.spriteComponent.node)
        //        mine.spriteComponent.node.zPosition = Layer.alien.rawValue
        let path = CGMutablePath()
        
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
        
        localForegrounds[foreGroundIndex].addChild(mine.spriteComponent.node)
        
        mine.spriteComponent.node.run(followLine)
        
        self.mines.append(mine)
    }
    
    var runOnce = true
    var scanNodeIndex:Int!
    var foreGroundIndex:Int!
    var toggle = true
    var playerToKill: PlayerEntity!
    var tweek: CGFloat?
    
    
    override func update(deltaTime seconds: TimeInterval) {
        tweek = (localForegrounds.first?.size.width)!
        if runOnce {
            spriteShadow = (self.spriteComponent.node.userData?.object(forKey: "shadow") as? EntityNode)!
            spriteShadow?.alpha = 0.5
            playerToKill = (self.spriteComponent.node.userData?.object(forKey: "player") as? PlayerEntity)!
            runOnce = false
            
        }
        
        if toggle {
            
            toggle = false
//            let rand = GKRandomSource.sharedRandom().nextInt(upperBound: 2)
            let pause = SKAction.wait(forDuration: TimeInterval(0.1))
            let bomb = SKAction.run {
                let rand = GKRandomSource.sharedRandom().nextInt(upperBound: 8)
                if rand == 4 {
                    let playerPos = self.whereIsPlayer()
                    if playerPos == self.foreGroundIndex {
                        self.beginBombing(loop: 0, skew: rand)
                    }
                }
            }
            
            // CHANGE this so mutant gives up @ some point
            let move = SKAction.run {
                self.toggle = true
                // foreground index is the number of the foreground that the mutant is on right now...
                

                    var newG = self.localForegrounds[self.foreGroundIndex].convert(self.spriteComponent.node.position, to: self.playerToKill.spriteComponent.node)
//                    if self.tweek! > CGFloat(0) {
//                        newG.x = newG.x + self.tweek!
//                        self.tweek! -= 8
//                    }
                    print("newG \(newG) \(self.foreGroundIndex) \(self.spriteComponent.node.position)")
                    let randX = CGFloat(GKRandomSource.sharedRandom().nextInt(upperBound: 8))
                    let randY = CGFloat(GKRandomSource.sharedRandom().nextInt(upperBound: 8))
                    
                    if newG.x > 0 {
                        self.spriteComponent.node.position.x -= 8 + randX
                        self.spriteShadow?.position.x = self.spriteComponent.node.position.x
//
                    } else {
                        self.spriteComponent.node.position.x += 8 + randX
                        self.spriteShadow?.position.x = self.spriteComponent.node.position.x
//
                    }
                    
                    if newG.y > 0 {
                        self.spriteComponent.node.position.y -= 8 + randY
                        self.spriteShadow?.position.y = self.spriteComponent.node.position.y
//                        self.spriteShadow?.position.y -= 8 + randY
                    } else {
                        self.spriteComponent.node.position.y += 8 - randY
                        self.spriteShadow?.position.y = self.spriteComponent.node.position.y
//                        self.spriteShadow?.position.y += 8 - randY
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
        
        
        if spriteComponent.node.zRotation.radiansToDegrees() > 10 {
            spriteComponent.node.run(SKAction.rotate(toAngle: CGFloat(-20).degreesToRadians(), duration: 0.5))
        } else {
            spriteComponent.node.run(SKAction.rotate(toAngle: CGFloat(20).degreesToRadians(), duration: 0.5))
        }
        
        if spriteComponent.node.position.x < 0 {
            if spriteComponent.node.parent != nil {
                spriteComponent.node.removeFromParent()
                foreGroundIndex -= 1
                if foreGroundIndex < 0 {
                    foreGroundIndex = 7
                }
            }
            spriteComponent.node.position.x = 2048
            localForegrounds[foreGroundIndex].addChild(spriteComponent.node)
            if spriteShadow?.parent != nil {
                spriteShadow?.removeFromParent()
                scanNodeIndex -= 1
                if scanNodeIndex < 0 {
                    scanNodeIndex = 7
                }
            }
            spriteShadow?.position.x = 2048
            localScan[scanNodeIndex].addChild(spriteShadow!)
        }
        
        if spriteComponent.node.position.x > 2048 {
            if spriteComponent.node.parent != nil {
                spriteComponent.node.removeFromParent()
                foreGroundIndex += 1
                if foreGroundIndex == 8 {
                    foreGroundIndex = 0
                }
                spriteComponent.node.position.x = 0
                localForegrounds[foreGroundIndex].addChild(spriteComponent.node)
            }
            if spriteShadow?.parent != nil {
                spriteShadow?.removeFromParent()
                scanNodeIndex += 1
                if scanNodeIndex == 8 {
                    scanNodeIndex = 0
                }
                spriteShadow?.position.x = 0
                localScan[scanNodeIndex].addChild(spriteShadow!)
            }
        }
    }
}

