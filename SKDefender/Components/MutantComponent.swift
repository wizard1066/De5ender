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
    var playableRegion: CGFloat = UIScreen.main.bounds.maxY * 2 * 0.8
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
    
    func findPathToExecute(random: Int) -> (CGPoint, CGPoint) {
        var directionToGoA: CGPoint
        var directionToGoB: CGPoint
        switch random {
        case 0:
            directionToGoA = CGPoint(x: 0, y: -512)
            directionToGoB = CGPoint(x: 0, y: -512)
            break
        case 1:
            directionToGoA = CGPoint(x: 0, y: 512)
            directionToGoB = CGPoint(x: 0, y: 512)
            break
        case 2:
            directionToGoA = CGPoint(x: -512, y: 0)
            directionToGoB = CGPoint(x: -512, y: 0)
            break
        case 3:
            directionToGoA = CGPoint(x: 512, y: 0)
            directionToGoB = CGPoint(x: 512, y: 0)
            break
        default:
            directionToGoA = CGPoint(x: 0, y: 0)
            directionToGoB = CGPoint(x: 0, y: 0)
            break
        }
        return (directionToGoA, directionToGoB)
    }
    
    func beginBombing(loop: Int, skew: Int) {
        // stop bombing if mutant is dead
        if self.spriteComponent.node.parent == nil {
            return
        }
        
        let mine = BombEntity(imageName: "mine", owningNode: self.spriteComponent.node)
        //        mine.spriteComponent.node.zPosition = Layer.alien.rawValue
        let path = CGMutablePath()
        
        mine.spriteComponent.node.position = CGPoint.zero
        path.move(to: CGPoint.zero)

        var pathToExecute: CGPoint!
        let (d2A, d2B) = findPathToExecute(random: skew)
        if skew % 2 == 0 {
            let newX = d2A.x + CGFloat(skew)
            let newY = d2A.y + CGFloat(skew)
            pathToExecute = CGPoint(x: newX, y: newY)
        } else {
            let newX = d2B.x + CGFloat(skew)
            let newY = d2B.y + CGFloat(skew)
            pathToExecute = CGPoint(x: newX, y: newY)
        }
        path.addLine(to: pathToExecute)
        let followLine = SKAction.follow(path, speed: 64)
        
        self.spriteComponent.node.addChild(mine.spriteComponent.node)
        
        mine.spriteComponent.node.run(followLine)
        
        self.mines.append(mine)
    }
    
    var runOnce = true
    var scanNodeIndex:Int!
    var foreGroundIndex:Int!
    var toggle = true
    var playerToKill: PlayerEntity!
    var runLess: Int = 0
    var runFrame: Int = 0
    var running: spriteAttack?
    var randQ: Int = 0
    
    func setRunning(value2D: spriteAttack) {
        running = value2D
    }
    
    
    override func update(deltaTime seconds: TimeInterval) {
        if runOnce {
            spriteShadow = (self.spriteComponent.node.userData?.object(forKey: "shadow") as? EntityNode)!
            spriteShadow?.alpha = 0.5
            playerToKill = (self.spriteComponent.node.userData?.object(forKey: "player") as? PlayerEntity)!
            runOnce = false
            
        }
        
        if runLess < 120 + randQ {
            runLess += 1
        } else {
            self.randQ = GKRandomSource.sharedRandom().nextInt(upperBound: 4)
            self.beginBombing(loop: self.randQ, skew: self.randQ)
            runLess = 0
        }
        
        if runFrame < 60 {
            
        } else {
            
        }
        
        if toggle {
            toggle = false
            let pause = SKAction.wait(forDuration: TimeInterval(0.1))
            let move = SKAction.run {
                self.toggle = true
                // foreground index is the number of the foreground that the mutant is on right now...
                
                    var newG = self.localForegrounds[self.foreGroundIndex].convert(self.spriteComponent.node.position, to: self.playerToKill.spriteComponent.node)
                    switch self.running {
                        case .cominNorth?:
                            newG.y = newG.y - 128
                            break
                        case .cominSouth?:
                            newG.y = newG.y + 128
                            break
                        default:
                            break
                        }
                

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
            
                    let playerIndex = self.whereIsPlayer()
                    if self.foreGroundIndex == playerIndex {
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
                
            }
//            let amountToRotate:CGFloat = 0.5
//            let rotateClockwise = SKAction.rotate(byAngle: amountToRotate.degreesToRadians(), duration: 0.2)
            spriteComponent.node.run(SKAction.sequence([pause,move]))
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

