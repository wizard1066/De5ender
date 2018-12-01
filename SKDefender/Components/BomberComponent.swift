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
//    var localView: EntityNode!
    var localScan:[EntityNode] = []
    var localForeground:[EntityNode] = []
    var spriteShadow: EntityNode?
    var mines:[MineEntity] = []
    var bounds: CGRect!
    var directionToGo: spriteAttack!
    
    init(entity: GKEntity, screenBounds: CGRect, view2D: EntityNode, scanNodes: [EntityNode], foregrounds: [EntityNode], shadow:EntityNode?) {
        localBounds = screenBounds
//        localView = view2D
        localScan = scanNodes
        localForeground = foregrounds
        bounds = screenBounds
        
        self.spriteComponent = entity.component(ofType: SpriteComponent.self)!
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func returnBomberPosition() -> CGPoint {
        return spriteComponent.node.position
    }
    
//    public func setScreen(entity: EntityNode) {
//        localView = entity
//    }
    
    func beginBombing(loop: Int, bomber: EntityNode) {
        let mine = MineEntity(imageName: "mine", owningNode: self.spriteComponent.node)
        mine.spriteComponent.node.position = spriteComponent.node.position
        localForeground[foreGroundIndex].addChild(mine.spriteComponent.node)
        self.mines.append(mine)
    }
    
    var runOnce = true
    var scanNodeIndex:Int!
    var foreGroundIndex:Int!
    var toggle = true
    var change = false
    var band:CGFloat = 1.6
    
    func setVariable(sceneNo: Int, direction: spriteAttack) {
        foreGroundIndex = sceneNo
        scanNodeIndex = sceneNo
        directionToGo = direction
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        for mine in mines {
            if mine.mineComponent.lifetime != 8 {
                mine.update(deltaTime: seconds)
            }
        }
        if spriteComponent.node.parent == nil {
            spriteShadow?.removeFromParent()
            return
        }
        
        if runOnce {
            spriteShadow = (self.spriteComponent.node.userData?.object(forKey: "shadow") as? EntityNode)!
            spriteShadow?.alpha = 0.5
            runOnce = false
            beginBombing(loop: 0, bomber: spriteComponent.node)
        }
        
        if toggle {
            beginBombing(loop: 0, bomber: spriteComponent.node)
            toggle = false
            let rand = GKRandomSource.sharedRandom().nextInt(upperBound: 8)
            let pause = SKAction.wait(forDuration: TimeInterval(rand))
            let bomb = SKAction.run {
                self.toggle = true
            }
            spriteComponent.node.run(SKAction.sequence([pause,bomb]))
        }
        
//        for mine in mines {
//            mine.update(deltaTime: seconds)
//        }

        if directionToGo == .cominEast {
            spriteComponent.node.position.x -= 2
            spriteShadow?.position.x -= 2
        } else {
            spriteComponent.node.position.x += 2
            spriteShadow?.position.x += 2
        }
        
        if spriteComponent.node.position.y < bounds.maxY * band && !change {
            spriteComponent.node.position.y += 1
            self.spriteShadow?.position.y = self.spriteComponent.node.position.y
            change = false
        } else {
            change = true
            if spriteComponent.node.position.y > bounds.minY + 128 {
                spriteComponent.node.position.y -= 1
                self.spriteShadow?.position.y = self.spriteComponent.node.position.y
            } else {
                change = false
            }
        }
        
   
        
        if spriteComponent.node.position.x < 0 {
            if spriteComponent.node.parent != nil {
                foreGroundIndex -= 1
                if foreGroundIndex < 0 {
                    foreGroundIndex = 7
                }
            }
            spriteComponent.node.position.x = 2048
            if spriteComponent.node.parent != nil {
                spriteComponent.node.removeFromParent()
                localForeground[foreGroundIndex].addChild(spriteComponent.node)
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
        }
        
        if spriteComponent.node.position.x > 2048 {
            if spriteComponent.node.parent != nil {
                foreGroundIndex += 1
                if foreGroundIndex == 8 {
                    foreGroundIndex = 0
                }
                spriteComponent.node.position.x = 0
                if spriteComponent.node.parent != nil {
                    spriteComponent.node.removeFromParent()
                    localForeground[foreGroundIndex].addChild(spriteComponent.node)
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
    
  
    
}
