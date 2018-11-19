//
//  AlienDecentComponent.swift
//  SKDefender
//
//  Created by localadmin on 12.11.18.
//  Copyright © 2018 ch.cqd.skdefender. All rights reserved.
//

import SpriteKit
import GameplayKit

class AlienDecentComponent: GKComponent {
    let spriteComponent: SpriteComponent
    
    var playableStart: CGFloat = 0
    var playableRegion: CGFloat = UIScreen.main.bounds.maxY * 2
    var decentRate: CGFloat = -0.5
    
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

    func getSpaceMan() {
        if let _ = spriteComponent.node.action(forKey: "getSpaceMan") {
            // do nothing
        } else {
            print("runAction")
            let maxY = UIScreen.main.bounds.maxY - 200
            let getSpaceMan = SKAction.move(to: CGPoint(x: spriteComponent.node.position.x, y: 96), duration: 4)
            spriteComponent.node.run(getSpaceMan, withKey: "getSpaceMan")
        }
    }

    func stopSpaceMan() {
//        let maxY = UIScreen.main.bounds.maxY * 2
        spriteComponent.node.removeAction(forKey: "getSpaceMan")
        print("running \(runningAction())")
    
        if let _ = spriteComponent.node.action(forKey: "rtnSpaceMan") {
            // do nothing
        } else {
            let rtnSpaceMan = SKAction.move(to: CGPoint(x: spriteComponent.node.position.x, y: 512), duration: 4)
            spriteComponent.node.run(rtnSpaceMan, withKey: "rtnSpaceMan")
        }
    }
    
    func sayHello() {
        print("HelloWorld")
    }
    
    public func returnAlienPosition() -> CGPoint {
        return spriteComponent.node.position
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        spriteComponent.node.position.y = spriteComponent.node.position.y + decentRate

        if spriteComponent.node.position.y - spriteComponent.node.size.height / 2 < playableStart {
            changeDirection(seconds)
        }

        if spriteComponent.node.position.y + spriteComponent.node.size.height > playableRegion {
            let fadeAway = SKAction.fadeOut(withDuration: 0.5)
            let selfDestruct = SKAction.removeFromParent()
            spriteComponent.node.run(SKAction.sequence([fadeAway,selfDestruct]))
        }
    }
    
    func sinePath(screenBounds: CGRect) -> CGPath {
        
        let graphWidth: CGFloat = 0.8  // Graph is 80% of the width of the view
        let amplitude: CGFloat = 0.3   // Amplitude of sine wave is 30% of view height
        
        let width = screenBounds.width * 2
        let height = screenBounds.height * 0.50
        
        let origin = CGPoint(x: 0, y: height * 0.50)
        
        let path = UIBezierPath()
        path.move(to: origin)
        
        for angle in stride(from: 5.0, through: 360.0, by: 5.0) {
            let x = origin.x + CGFloat(angle/360.0) * width * graphWidth
            let y = origin.y - CGFloat(sin(angle/180.0 * Double.pi)) * height * amplitude
            path.addLine(to: CGPoint(x: x, y: y))
        }
        
        
        
        return path.cgPath
    }

}
