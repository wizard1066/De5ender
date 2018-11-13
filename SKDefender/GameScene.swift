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
    static let Alien: UInt32 = 0b1 << 4
}

class GameScene: SKScene, SKPhysicsContactDelegate, touchMe {
    
    var moveLeft = false
    var moveRight = false
    
    enum Layer: CGFloat {
        case background
        case foreground
        case player
        case spaceman
        case alien
    }
    
    
    let player = PlayerEntity(imageName: "starship")
    
    let alien = AlienEntity(imageName: "alien")
    
    
    var playableStart: CGFloat = 0
    
    var deltaTime: TimeInterval = 0
    var lastUpdateTimeInterval: TimeInterval = 0
    
    let numberOfForegrounds = 2
    var groundSpeed:Double = 150
    var brakeSpeed:Double = 0.1
    
    lazy var screenWidth = view!.bounds.width
    lazy var screenHeight = view!.bounds.height
    
    func buildGround(color: UIColor) -> (SKTexture, CGMutablePath) {
        let loopsNeeded = Int(screenWidth / 120)
        var path: CGMutablePath?
        var lastValue = 96
        for loop in stride(from: 0, to: Int(screenWidth*2), by: loopsNeeded) {
            let randomSource = GKARC4RandomSource()
            let randomDistribution = GKRandomDistribution(randomSource: randomSource, lowestValue: 80, highestValue: 128)
            let randomValueY = randomDistribution.nextInt()
            if path == nil {
                path = CGMutablePath()
                path!.move(to: CGPoint(x: 0, y: lastValue))
            } else {
                path!.addLine(to: CGPoint(x: loop, y: randomValueY))
            }
            if loop + loopsNeeded > Int(screenWidth*2) {
                lastValue = randomValueY
            }
        }
        
        let shape = SKShapeNode()
        shape.path = path
        shape.strokeColor = color
        shape.lineWidth = 2
        shape.zPosition = 1
        
        let texture = view?.texture(from: shape)
        return (texture!,path!)
    }
    
    func setupForeground() {
        
        var color2U:UIColor!
        for i in 0..<numberOfForegrounds {
            if i == 0 {
                color2U = UIColor.red
            } else {
                color2U = UIColor.red
            }
            let (texture, path) = buildGround(color: color2U)
            let foreground = BuildEntity(texture: texture, path: path, i: i)
            let foregroundNode = foreground.buildComponent.node
            addChild(foregroundNode)
            let spaceManCords = CGPoint(x: view!.bounds.maxX + 256, y: view!.bounds.minY + 96)
            let spaceMan = RescueEntity(imageName: "spaceMan", position: spaceManCords)
            let spaceNode = spaceMan.rescueComponent.node
            spaceNode.delegate = self
//            spaceNode.position = CGPoint(x: self.view!.bounds.maxX + 256, y: self.view!.bounds.minY + 96)
            spaceNode.zPosition = Layer.spaceman.rawValue
            spaceNode.delegate = self
            if spaceNode.parent == nil {
                foregroundNode.addChild(spaceNode)
            }
            let alienNode = alien.spriteComponent.node
            alienNode.position = CGPoint(x: self.view!.bounds.maxX + 256, y: self.view!.bounds.maxY)
            alienNode.zPosition = Layer.alien.rawValue
            alienNode.delegate = self
            if alienNode.parent == nil {
                foregroundNode.addChild(alienNode)
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
    
    
    
    var playerNode: EntityNode!
    var advanceArrow: TouchableSprite!
    
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
        
        advanceArrow = TouchableSprite(imageNamed: "RightArrow")
        advanceArrow.position = CGPoint(x: ((self.view?.bounds.maxX)! * 2) - 128, y: ((self.view?.bounds.maxY)!) - 64)
        advanceArrow.size = CGSize(width: 64, height: 64)
        advanceArrow.name = "advance"
        advanceArrow.delegate = self
        
        
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
        addChild(advanceArrow)

        addChild(pauseSquare)
        addChild(flipButton)
        
        
    }
    
    var cameraNode: SKCameraNode!
    var cameraNode2: SKCameraNode!
    var subWin: SKScene!
    
    override func didMove(to view: SKView) {
        /* Setup your scene here */
        physicsWorld.gravity = CGVector(dx: 0, dy: -0.5)
        physicsWorld.contactDelegate = self
        
        cameraNode = SKCameraNode()
        cameraNode.position = CGPoint(x: self.view!.bounds.maxX, y: self.view!.bounds.maxY)
        scene?.camera = cameraNode
        
        cameraNode.setScale(2)
        
        addChild(cameraNode)
        
        setupForeground()
        setupPlayer()
        
//        Add a boundry to the screen
        let rectToSecure = CGRect(x: 0, y: 0, width: self.view!.bounds.maxX * 2, height: self.view!.bounds.minX * 2)
        physicsBody = SKPhysicsBody(edgeLoopFrom: rectToSecure)
        physicsBody?.isDynamic = false

        
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
            lowerSpeed()
        }
        if moveRight {
            updateForegroundRight()
            lowerSpeed()
        }
        player.update(deltaTime: deltaTime)
        alien.update(deltaTime: deltaTime)
        
    }
    
    func lowerSpeed() {
        if groundSpeed > 24 {
            groundSpeed = groundSpeed - brakeSpeed
        } else {
            groundSpeed = 24
        }
    }
    
    func moreBreak() {
        brakeSpeed = brakeSpeed * 2
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        let pointTouched = touches.first?.location(in: self.view)
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
        let kidnap = contact.bodyA.categoryBitMask == PhysicsCat.Alien ? contact.bodyB : contact.bodyA
        let hit = contact.bodyA.categoryBitMask == PhysicsCat.Fire ? contact.bodyB : contact.bodyA
        
        // alien kidnaps spaceman

        if kidnap.node?.name == "spaceman" && kidnap.node?.parent?.name == "foreground" && contact.bodyB.node!.name == "alien" {
            print("rule I")
            pickup = other.node?.position
            kidnap.node?.removeFromParent()
            kidnap.node?.position = CGPoint(x: 0, y: -96)
            contact.bodyB.node?.addChild(kidnap.node!)
            self.alien.alienComponent.changeDirection(self.lastUpdateTimeInterval)
            return
        }
        
        // drop spaceman if ground touches him
        
        if other.node?.name == "spaceman" && other.node?.parent?.name == "foreground" && contact.bodyB.node!.name == "starship" {
//        if other.node?.name == "spaceman" && contact.bodyB.node!.name == "starship" {
            print("rule II")
            pickup = other.node?.position
            other.node?.removeFromParent()
            other.node?.position = CGPoint(x: 0, y: -96)
            other.node?.physicsBody?.isDynamic = false
            contact.bodyB.node?.addChild(other.node!)
            return
        }
        
        // drop spaceman if ground touches him while carried by starship
        
        if other.node?.name == "foreground" && contact.bodyB.node?.name == "starship"{
            print("rule III")
            let saving = contact.bodyB.node?.childNode(withName: "spaceman")
            if saving != nil {
//                saving?.position = (other.node?.position)!
                saving?.position.x = self.playerNode.position.x - (other.node?.position.x)!
                saving?.position.y = 96
                saving?.removeFromParent()
                other.node?.addChild(saving!)
            }
            return
        }
        
        // alien hit, releases spaceman

        if hit.node?.name == "alien" {
            print("rule IV")
            let victim = hit.node?.childNode(withName: "spaceman")
            let parent2U = hit.node?.parent
            hit.node?.removeFromParent()
            if victim != nil {
                victim?.position = (hit.node?.position)!
                victim?.removeFromParent()
                victim?.physicsBody?.isDynamic = true
                parent2U?.addChild(victim!)
            }
            return
        }
        
        // spaceman falling to ground
        
        if other.node?.name == "foreground" {
            print("rule V")
            contact.bodyB.node?.physicsBody?.isDynamic = false
            let poc = CGPoint(x: (contact.bodyB.node?.position.x)!, y: 96)
            contact.bodyB.node?.run(SKAction.move(to: poc, duration: 0.5))
            return
        }
        
        // shoot the spaceman and he will disppear
        
        if hit.node?.name == "spaceman" && contact.bodyB.node?.name != "starship" {
            print("rule VI \(contact.bodyB.node?.name)")
            hit.node?.removeFromParent()
        }
    }
    
    var previousDirection:String?
    
    func spriteTouched(box: TouchableSprite) {
        switch box.name {
        case "starship":
            print("groundSpeed \(groundSpeed)")
        case "spaceman":
            print("cords \(box.position) \(moveAmount)")
        case "up":
            player.movementComponent.applyImpulseUp(lastUpdateTimeInterval)
        case "down":
            player.movementComponent.applyImpulseDown(lastUpdateTimeInterval)
        case "advance":
            let direct = playerNode.userData?.object(forKey: "direction") as? String
            if previousDirection == nil || previousDirection != direct {
                groundSpeed = 150
                brakeSpeed = 0.1
                previousDirection = direct
            } else {
                groundSpeed += 30
                previousDirection = direct
            }
            switch direct {
            case "left":
                moveRight = true
                moveLeft = false
                player.movementComponent.applyImpulseX(lastUpdateTimeInterval)
            case "right":
                moveRight = false
                moveLeft = true
                player.movementComponent.applyImpulseX(lastUpdateTimeInterval)
            default:
                break
            }
        //                player.movementComponent.applyImpulseLeft(lastUpdateTimeInterval)
        case "flip":
            let direct = playerNode.userData?.object(forKey: "direction") as? String
            groundSpeed = 150
            brakeSpeed = 0.1
            switch direct {
            case "left":
                advanceArrow.texture = SKTexture(imageNamed: "RightArrow")
                // moveRight/moveLet control the background direction
                moveLeft = true
                moveRight = false
                player.movementComponent.applyImpulseLeft(lastUpdateTimeInterval)
            case "right":
                advanceArrow.texture = SKTexture(imageNamed: "LeftArrow")
                moveRight = true
                moveLeft = false
                player.movementComponent.applyImpulseRight(lastUpdateTimeInterval)
                
            default:
                break
            }
        case "fire":
            let mshape = CGRect(x: 0, y: 0, width: 24, height: 6)
            let missileX = FireEntity(rect: mshape)
            
            let fireNode = missileX.shapeComponent.node
            fireNode.position = CGPoint(x: 0, y: 0)
            fireNode.zPosition = Layer.alien.rawValue
            playerNode.addChild(fireNode)
            
            let direct = playerNode.userData?.object(forKey: "direction") as? String
            switch direct {
            case "left":
                missileX.pathComponent.releaseFireLeft(lastUpdateTimeInterval)
            case "right":
                missileX.pathComponent.releaseFireRight(lastUpdateTimeInterval)
            default:
                break
            }
        default:
            moreBreak()
//            player.movementComponent.applyZero(lastUpdateTimeInterval)
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
