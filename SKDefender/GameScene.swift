//
//  GameScene.swift
//  SKDefender
//
//  Created by localadmin on 06.11.18.
//  Copyright © 2018 ch.cqd.skdefender. All rights reserved.
//

import SpriteKit
import GameplayKit

struct PhysicsCat {
    static let None: UInt32 = 0
    static let Player: UInt32 = 0b1
    static let Ground: UInt32 = 0b1 << 1
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    enum Layer: CGFloat {
        case background
        case foreground
        case player
    }
    
    let player = PlayerEntity(imageName: "starship")
    var playableStart: CGFloat = 0
    
    var deltaTime: TimeInterval = 0
    var lastUpdateTimeInterval: TimeInterval = 0
    
    let numberOfForegrounds = 2
    let groundSpeed = 150
    
    lazy var screenWidth = view!.bounds.width
    lazy var screenHeight = view!.bounds.height
    
    func buildGround() -> SKSpriteNode {
        let loopsNeeded = Int(screenWidth / 80)
        var path: CGMutablePath?
        for loop in stride(from: 0, to: Int(screenWidth*2), by: loopsNeeded) {
            let randomSource = GKARC4RandomSource()
            let randomDistribution = GKRandomDistribution(randomSource: randomSource, lowestValue: 80, highestValue: 128)
            let randomValueY = randomDistribution.nextInt()
            if path == nil {
                path = CGMutablePath()
                path!.move(to: CGPoint(x: 0, y: randomValueY))
            } else {
                path!.addLine(to: CGPoint(x: loop, y: randomValueY))
            }
        }
        
        let shape = SKShapeNode()
        shape.path = path
        shape.strokeColor = UIColor.white
        shape.lineWidth = 2
        shape.zPosition = 1
//        shape.physicsBody = SKPhysicsBody(edgeLoopFrom: shape.path!)
//        shape.physicsBody = SKPhysicsBody(edgeChainFrom: shape.path!)
    
        let texture = view?.texture(from: shape)
        let sprite = SKSpriteNode(texture: texture)
//        sprite.physicsBody = SKPhysicsBody(edgeLoopFrom: shape.path!)
        sprite.physicsBody = SKPhysicsBody(edgeChainFrom: shape.path!)
        sprite.physicsBody?.categoryBitMask = PhysicsCat.Ground
        sprite.physicsBody?.collisionBitMask = 0
        sprite.physicsBody?.contactTestBitMask = PhysicsCat.Player
        
//        addChild(sprite)
        return sprite
    }
    
    func setupForeground() {
        for i in 0..<numberOfForegrounds {
            let foreground = buildGround()
            foreground.anchorPoint = CGPoint(x: 0.0, y: 0.0)
            foreground.position = CGPoint(x: CGFloat(i) * foreground.size.width, y: playableStart)
            foreground.zPosition = Layer.foreground.rawValue
            foreground.name = "foreground"
            addChild(foreground)
        }
    }
    
    func updateForeground() {
        self.enumerateChildNodes(withName: "foreground") { (node, stop) in
            if let foreground = node as? SKSpriteNode {
                let moveAmount = CGPoint(x: -CGFloat(self.groundSpeed) * CGFloat(self.deltaTime), y: self.playableStart)
                foreground.position.x += moveAmount.x
//                foreground.position.y += moveAmount.y
                
                if foreground.position.x < -foreground.size.width {
                    foreground.position.x += foreground.size.width * CGFloat(self.numberOfForegrounds)
                }
            }
        }
    }
    
    func setupPlayer() {
        let playerNode = player.spriteComponent.node
        playerNode.position = CGPoint(x: 128, y: 256)
        playerNode.zPosition = Layer.player.rawValue
//        playerNode.size = CGSize(width: playerNode.size.width/4, height: playerNode.size.height/4)
        addChild(playerNode)
        
//        player.movementComponent.playableStart = playableStart
    }
    
    override func didMove(to view: SKView) {
        /* Setup your scene here */
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsWorld.contactDelegate = self
//        buildGround()
        setupForeground()
        setupPlayer()
    }
    
    override func update(_ currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        if lastUpdateTimeInterval == 0 {
            lastUpdateTimeInterval = currentTime
        }
        
        deltaTime = currentTime - lastUpdateTimeInterval
        lastUpdateTimeInterval = currentTime
        
        updateForeground()
        player.update(deltaTime: deltaTime)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        player.movementComponent.applyImpulse(lastUpdateTimeInterval)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let other = contact.bodyA.categoryBitMask == PhysicsCat.Player ? contact.bodyB : contact.bodyA
        print("\(contact.bodyA.node!.name) \(contact.bodyB.node!.name)")
    }
}
