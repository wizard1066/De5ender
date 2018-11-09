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
    static let Fire: UInt32 = 0b1 << 2
    static let SpaceMan: UInt32 = 0b1 << 3
}

class GameScene: SKScene, SKPhysicsContactDelegate, touchMe {
    
    var moveLeft = false
    var moveRight = false
    
    
    func spriteTouched(box: TouchableSprite) {
        switch box.name {
        case "starship":
                print("cords \(box.position) \(moveAmount) \(foregroundCGPoint)")
            case "spaceman":
                print("cords \(box.position) \(moveAmount)")
            case "up":
                player.movementComponent.applyImpulseUp(lastUpdateTimeInterval)
            case "down":
                player.movementComponent.applyImpulseDown(lastUpdateTimeInterval)
//            case "left":
//                moveLeft = true
//                moveRight = false
//                player.movementComponent.applyImpulseRight(lastUpdateTimeInterval)
//            case "right":
//                moveRight = true
//                moveLeft = false
//                player.movementComponent.applyImpulseLeft(lastUpdateTimeInterval)
            case "flip":
                let direct = playerNode.userData?.object(forKey: "direction") as? String
                switch direct {
                case "left":
                    moveLeft = true
                    moveRight = false
                    player.movementComponent.applyImpulseLeft(lastUpdateTimeInterval)
                case "right":
                    moveRight = true
                    moveLeft = false
                    player.movementComponent.applyImpulseRight(lastUpdateTimeInterval)
                
                default:
                    break
                }
            case "fire":
                let missile = SKShapeNode(rect: CGRect(x: 0, y: 0, width: 24, height: 6))
                missile.fillColor = UIColor.red
                if missile.parent == nil {
                    playerNode.addChild(missile)
                    let path2F = SKAction.move(by: CGVector(dx: 1024, dy: 0), duration: 1)
                    let removeM = SKAction.removeFromParent()
                    missile.run(SKAction.sequence([path2F,removeM]))
                }
            default:
                moveLeft = false
                moveRight = false
                player.movementComponent.applyZero(lastUpdateTimeInterval)
        }
    }
    
    
    enum Layer: CGFloat {
        case background
        case foreground
        case player
        case spaceman
    }
    
    let player = PlayerEntity(imageName: "starship")
    let spaceMan = RescueEntity(imageName: "spaceMan")
    
    var playableStart: CGFloat = 0
    
    var deltaTime: TimeInterval = 0
    var lastUpdateTimeInterval: TimeInterval = 0
    
    let numberOfForegrounds = 2
    let groundSpeed = 150
    
    lazy var screenWidth = view!.bounds.width
    lazy var screenHeight = view!.bounds.height
    
    func buildGround(color: UIColor) -> SKSpriteNode {
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
        shape.strokeColor = color
        shape.lineWidth = 2
        shape.zPosition = 1
        
        let texture = view?.texture(from: shape)
        let sprite = SKSpriteNode(texture: texture)

        sprite.physicsBody = SKPhysicsBody(edgeChainFrom: shape.path!)
        sprite.physicsBody?.categoryBitMask = PhysicsCat.Ground
        sprite.physicsBody?.collisionBitMask = 0
        sprite.physicsBody?.contactTestBitMask = PhysicsCat.Player
        
        
//        addChild(sprite)
        return sprite
    }
    
    func setupForeground() {
        
        var color2U:UIColor!
        for i in 0..<numberOfForegrounds {
            if i == 0 {
                color2U = UIColor.red
            } else {
                color2U = UIColor.blue
            }
            let foreground = buildGround(color: color2U)
            print("foreground \(foreground.size.width)")
            foreground.anchorPoint = CGPoint(x: 0.0, y: -1.33)
            foreground.position = CGPoint(x: CGFloat(i) * foreground.size.width, y: playableStart)
            foreground.zPosition = Layer.foreground.rawValue
            foreground.name = "foreground"
            addChild(foreground)
            let spaceNode = spaceMan.rescueComponent.node
            spaceNode.delegate = self
            spaceNode.name = "spaceman"
            spaceNode.position = CGPoint(x: self.view!.bounds.maxX + 256, y: self.view!.bounds.minY + 512)
            spaceNode.zPosition = Layer.spaceman.rawValue
            if spaceNode.parent == nil {
                foreground.addChild(spaceNode)
            }
        }
    }
    
    var moveAmount: CGPoint!
    var foregroundCGPoint: CGFloat!
    
    func updateForegroundLeft() {
        self.enumerateChildNodes(withName: "foreground") { (node, stop) in
            if let foreground = node as? SKSpriteNode {
                self.moveAmount = CGPoint(x: -CGFloat(self.groundSpeed) * CGFloat(self.deltaTime), y: self.playableStart)
                foreground.position.x += self.moveAmount.x
                self.foregroundCGPoint = foreground.position.x
                
                if foreground.position.x < -foreground.size.width {
                    foreground.position.x += foreground.size.width * CGFloat(self.numberOfForegrounds)
                }
            }
        }
    }
    
    func updateForegroundRight() {
        self.enumerateChildNodes(withName: "foreground") { (node, stop) in
            if let foreground = node as? SKSpriteNode {
                self.moveAmount = CGPoint(x: -CGFloat(self.groundSpeed) * CGFloat(self.deltaTime), y: self.playableStart)
                foreground.position.x -= self.moveAmount.x
                self.foregroundCGPoint = foreground.position.x
                
                if foreground.position.x > foreground.size.width {
                    foreground.position.x -= foreground.size.width * CGFloat(self.numberOfForegrounds)
                }
            }
        }
    }
    
    func setupSpaceMen() {
        let spaceNode = spaceMan.rescueComponent.node
        spaceNode.position = CGPoint(x: self.view!.bounds.maxX + 256, y: self.view!.bounds.minY + 96)
        spaceNode.zPosition = Layer.spaceman.rawValue
        //        playerNode.size = CGSize(width: playerNode.size.width/4, height: playerNode.size.height/4)
        addChild(spaceNode)
    }
    
    var playerNode: EntityNode!
    
    func setupPlayer(){
        playerNode = player.spriteComponent.node
        playerNode.position = CGPoint(x: self.view!.bounds.maxX / 2, y: self.view!.bounds.maxY / 2)
        playerNode.zPosition = Layer.player.rawValue
//        playerNode.size = CGSize(width: playerNode.size.width/4, height: playerNode.size.height/4)
        playerNode.delegate = self
        addChild(playerNode)
        
        
//        player.movementComponent.playableStart = playableStart
  
        let upArrow = TouchableSprite(imageNamed: "UpArrow")
        upArrow.position = CGPoint(x: (self.view?.bounds.minX)! + 128, y: ((self.view?.bounds.maxY)!) + 64)
        upArrow.size = CGSize(width: 64, height: 64)
        upArrow.name = "up"
        upArrow.delegate = self
        
        let downArrow = TouchableSprite(imageNamed: "DownArrow")
        downArrow.position = CGPoint(x: (self.view?.bounds.minX)! + 128, y: ((self.view?.bounds.maxY)!) - 64)
        downArrow.size = CGSize(width: 64, height: 64)
        downArrow.name = "down"
        downArrow.delegate = self
        
        let stopSquare = TouchableSprite(imageNamed: "Square")
        stopSquare.position = CGPoint(x: (self.view?.bounds.minX)! + 128, y: ((self.view?.bounds.maxY)!))
        stopSquare.size = CGSize(width: 64, height: 64)
        stopSquare.name = "square"
        stopSquare.delegate = self
        
        let pauseSquare = TouchableSprite(imageNamed: "Square")
        pauseSquare.position = CGPoint(x: ((self.view?.bounds.maxX)! * 2) - 128, y: ((self.view?.bounds.maxY)!))
        pauseSquare.size = CGSize(width: 64, height: 64)
        pauseSquare.name = "fire"
        pauseSquare.delegate = self
        
        let flipButton = TouchableSprite(imageNamed: "SwiftLogo")
        flipButton.position = CGPoint(x: ((self.view?.bounds.maxX)! * 2) - 128, y: ((self.view?.bounds.maxY)!) - 256)
        flipButton.size = CGSize(width: 64, height: 64)
        flipButton.name = "flip"
        flipButton.delegate = self
        
        addChild(upArrow)
        addChild(downArrow)
        addChild(stopSquare)

        addChild(pauseSquare)
        addChild(flipButton)
        
        
    }
    
    var cameraNode: SKCameraNode!
    var cameraNode2: SKCameraNode!
    var subWin: SKScene!
    
    override func didMove(to view: SKView) {
        /* Setup your scene here */
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsWorld.contactDelegate = self
        cameraNode = SKCameraNode()
        cameraNode.position = CGPoint(x: self.view!.bounds.maxX, y: self.view!.bounds.maxY)
        scene?.camera = cameraNode
        
        cameraNode.setScale(2)
        
        addChild(cameraNode)
        
//        subWin = SKScene()
//        subWin.move(toParent: self)

//        let swiftCode = SKSpriteNode(imageNamed: "SwiftLogo")
//
//        swiftCode.position = CGPoint(x: self.view!.bounds.maxX, y: self.view!.bounds.maxY)
//        subWin.addChild(swiftCode)
//
//        cameraNode2 = SKCameraNode()
//        cameraNode2.position = CGPoint(x: self.view!.bounds.maxX, y: self.view!.bounds.maxY)
//        subWin?.camera = cameraNode2
//
//        cameraNode2.setScale(8)
//        subWin.addChild(cameraNode2)
        
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
        
        if moveLeft {
            updateForegroundLeft()
        }
        if moveRight {
            updateForegroundRight()
        }
        player.update(deltaTime: deltaTime)

    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let pointTouched = touches.first?.location(in: self.view)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let pointTouched = touches.first?.location(in: self.view)
        
        if pointTouched!.x < (self.view?.bounds.minX)! + 128, pointTouched!.y < ((self.view?.bounds.midY)!){
            player.movementComponent.applyImpulseUp(lastUpdateTimeInterval)
            return
        }
        if pointTouched!.x < (self.view?.bounds.minX)! + 128, pointTouched!.y > ((self.view?.bounds.midY)!){
            player.movementComponent.applyImpulseDown(lastUpdateTimeInterval)
            return
        }
//        if pointTouched!.x > (self.view?.bounds.maxX)! - 128, pointTouched!.x < (self.view?.bounds.maxX)! - 64 {
//            player.movementComponent.applyImpulseLeft(lastUpdateTimeInterval)
//        }
//        if pointTouched!.x > (self.view?.bounds.maxX)! - 64, pointTouched!.x > ((self.view?.bounds.maxX)!){
//            player.movementComponent.applyImpulseRight(lastUpdateTimeInterval)
//        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("ended")
    }
    
    var pickup: CGPoint!
    
    var playerCG: CGFloat!
    
    func didBegin(_ contact: SKPhysicsContact) {
        let other = contact.bodyA.categoryBitMask == PhysicsCat.Player ? contact.bodyB : contact.bodyA
//        print("\(contact.bodyA.node!.name) \(contact.bodyB.node!.name)")
//         pickup space man if starship touches him TECHNICALLLY WRONG never happens in tha game
        if other.node?.name == "spaceman" && other.node?.parent?.name == "foreground" {
            print("pickup \(other.node?.position)")
            pickup = other.node?.position
            let rmNode = SKAction.run {
                other.node?.removeFromParent()
            }
            let addNode = SKAction.run {
                other.node?.position = CGPoint(x: 0, y: -96)

                if other.node?.parent == nil {
                    contact.bodyB.node?.addChild(other.node!)
                }
            }
            contact.bodyB.node?.run(SKAction.sequence([rmNode,addNode]))
        }
        // drop spaceman if ground touches him
        if other.node?.name == "foreground" && contact.bodyB.node?.name == "spaceman" {
            let rmNode = SKAction.run {
                contact.bodyB.node?.removeFromParent()
            }
            let addNode = SKAction.run {
                
//                contact.bodyB.node?.position.x = self.playerNode.position.x
//                contact.bodyB.node?.position.x = self.foregroundCGPoint
//                self.playerCG = self.playerNode.position.x
                contact.bodyB.node?.position.x = self.playerNode.position.x - (other.node?.position.x)!
                
                contact.bodyB.node?.position.y = 96
                if contact.bodyB.node?.parent == nil {
                    other.node?.addChild(contact.bodyB.node!)
                }
            }
            other.node?.run(SKAction.sequence([rmNode,addNode]))
        }
    }
}

public extension CGFloat {
    public func degreesToRadians() -> CGFloat {
        return CGFloat.pi * self / 180.0
    }

    public func radiansToDegrees() -> CGFloat {
        return self * 180.0 / CGFloat.pi
    }
}
