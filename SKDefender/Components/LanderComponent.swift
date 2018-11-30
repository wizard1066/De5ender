//
//  LanderComponent.swift
//  SKDefender
//
//  Created by localadmin on 27.11.18.
//  Copyright © 2018 ch.cqd.skdefender. All rights reserved.
//

import SpriteKit
import GameplayKit

class LanderComponent: GKComponent {
    let spriteComponent: SpriteComponent
    
    var playableStart: CGFloat = 0
    var playableRegion: CGFloat = UIScreen.main.bounds.maxY * 2
    var decentRate: CGFloat = -0.5
    var mines:[BaitEntity] = []
    var localForegrounds:[EntityNode] = []
    var playerToKill: EntityNode!
    var foreGroundIndex:Int!
    var scanNodeIndex:Int!
    
    init(entity: GKEntity, screenBounds: CGRect) {
        self.spriteComponent = entity.component(ofType: SpriteComponent.self)!
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func changeDirection(_ lastUpdateTime: TimeInterval) {
        decentRate = 0.5
    }
    
    func runningAction() -> Bool {
        if let _ = spriteComponent.node.action(forKey: "getSpaceMan") {
            return true
        } else {
            return false
        }
    }
    
    public func setVariables(foregrounds:[EntityNode], playerNode: EntityNode, sceneNo: Int) {
        localForegrounds = foregrounds
        playerToKill = playerNode
        foreGroundIndex = sceneNo
        scanNodeIndex = sceneNo
    }
    
    func findPathToExecute() -> (CGPoint, CGPoint) {
        var directionToGoA: CGPoint
        var directionToGoB: CGPoint
        switch self.running {
        case .cominNorth?:
            directionToGoA = CGPoint(x: 0, y: 0)
            directionToGoB = CGPoint(x: 512, y: 64)
            break
        case .cominSouth?:
            directionToGoA = CGPoint(x: 0, y: 0)
            directionToGoB = CGPoint(x: -512, y: 64)
            break
        case .cominWest?:
            directionToGoA = CGPoint(x: 0, y: 0)
            directionToGoB = CGPoint(x: 512, y: 0)
            break
        case .cominEast?:
            directionToGoA = CGPoint(x: 0, y: 0)
            directionToGoB = CGPoint(x: -512, y: 0)
            break
        default:
            directionToGoA = CGPoint(x: 0, y: 0)
            directionToGoB = CGPoint(x: 0, y: 0)
            break
        }
        return (directionToGoA, directionToGoB)
    }
    
    func beginBombing(loop: Int, skew: Int) {
        print("beginBoming \(skew)")
        let mine = BaitEntity(imageName: "mine", owningNode: self.spriteComponent.node)
        //        mine.spriteComponent.node.zPosition = Layer.alien.rawValue
        
        let path = CGMutablePath()
        //        mine.spriteComponent.node.position = self.spriteComponent.node.position
        //        path.move(to: self.spriteComponent.node.position)
        mine.spriteComponent.node.position = CGPoint.zero
        path.move(to: CGPoint.zero)
        var pathToExecute: CGPoint!
        let (d2A, d2B) = findPathToExecute()
        if skew % 2 == 0 {
            let newX = d2A.x
            let newY = d2A.y
            pathToExecute = CGPoint(x: newX, y: newY)
        } else {
            let newX = d2B.x
            let newY = d2B.y
            pathToExecute = CGPoint(x: newX, y: newY)
        }
        path.addLine(to: pathToExecute)
        print("beginBoming \(path)")
        
        let followLine = SKAction.follow(path, speed: 64)
        
        //        localForegrounds[foreGroundIndex].addChild(mine.spriteComponent.node)
        self.spriteComponent.node.addChild(mine.spriteComponent.node)
        
        mine.spriteComponent.node.run(followLine)
        
        self.mines.append(mine)
    }
    
    public func returnAlienPosition() -> CGPoint {
        return spriteComponent.node.position
    }
    
    public func whereIsPlayer() -> Int {
        var indexToReturn = 0
        for foreground in localForegrounds {
            if playerToKill.position.x < foreground.frame.minX || playerToKill.position.x > foreground.frame.maxX {
                // do nothing
            } else {
                return indexToReturn
            }
            indexToReturn += 1
        }
        return indexToReturn
    }
    
    var runOnce = true
    var spriteShadow: EntityNode?
    var running: spriteAttack?
    var runLess: Int? = 0
    var randQ: Int = 0
    
    override func update(deltaTime seconds: TimeInterval) {
        if runOnce {
            spriteShadow = (self.spriteComponent.node.userData?.object(forKey: "shadow") as? EntityNode)!
            spriteShadow?.alpha = 0.5
            runOnce = false
            
        }
        spriteComponent.node.position.y = spriteComponent.node.position.y + decentRate
        spriteShadow?.position.y = spriteComponent.node.position.y
        
        if spriteComponent.node.position.y - spriteComponent.node.size.height / 2 < playableStart {
            changeDirection(seconds)
        }
        
        if spriteComponent.node.position.y + spriteComponent.node.size.height > playableRegion {
            let fadeAway = SKAction.fadeOut(withDuration: 0.5)
            let selfDestruct = SKAction.removeFromParent()
            spriteComponent.node.run(SKAction.sequence([fadeAway,selfDestruct]))
        }
        
        if spriteComponent.node.parent == nil {
            spriteShadow?.removeFromParent()
        }
        
        for mine in mines {
            mine.update(deltaTime: seconds)
        }
        
        let playerIndex = self.whereIsPlayer()
        
        
        if self.foreGroundIndex == playerIndex {
            var newG = self.localForegrounds[self.foreGroundIndex].convert(self.spriteComponent.node.position, to: self.playerToKill)
            if newG.x > 0 {
                self.running = .cominEast
            } else {
                self.running = .cominWest
            }
            
            if runLess! < 240 + randQ {
                runLess! += 1
            } else {
                self.randQ = GKRandomSource.sharedRandom().nextInt(upperBound: 4)
                self.beginBombing(loop: self.randQ, skew: self.randQ)
                runLess = 0
            }
        }
    }
}

