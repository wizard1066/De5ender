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
    
    init(entity: GKEntity, screenBounds: CGRect) {
        localBounds = screenBounds
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
    
    public func pathToTake() {
        let path = CGMutablePath()
        path.move(to:CGPoint(x: spriteComponent.node.position.x, y: spriteComponent.node.position.y))
        path.addLine(to: CGPoint(x: 0, y: 0))
        var followLine = SKAction.follow(path, asOffset: true, orientToPath: false, duration: 8.0)
        spriteComponent.node.run(followLine)
    }
    
    var justOnce = true
    override func update(deltaTime seconds: TimeInterval) {
        if justOnce {
            pathToTake()
            justOnce = false
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
