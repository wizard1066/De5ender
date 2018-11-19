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
    static let Bomber: UInt32 = 0b1 << 5
    static let Bomb: UInt32 = 0b1 << 6
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
    
    var player:PlayerEntity!
    var shadow:PlayerEntity!
//    var alien:AlienEntity!
    var peopleE: RescueEntity!
    var aliensE: AlienEntity!
    
    var playableStart: CGFloat = 0
    
    var deltaTime: TimeInterval = 0
    var lastUpdateTimeInterval: TimeInterval = 0
    
    let numberOfForegrounds = 4
    var groundSpeed:CGFloat = 150
    var brakeSpeed:CGFloat = 0.1
    
    lazy var screenWidth = view!.bounds.width
    lazy var screenHeight = view!.bounds.height
    
    func buildGround(color: UIColor) -> (SKTexture, CGMutablePath) {
        let loopsNeeded = Int(screenWidth / 128)
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
    
    var aliens:[GKEntity] = []
    var peoples:[EntityNode] = []
    var others:[EntityNode] = []
    var foregrounds:[EntityNode] = []
    var scanNodes:[EntityNode] = []
    var colours = [UIColor.red, UIColor.blue, UIColor.green, UIColor.magenta, UIColor.purple, UIColor.orange, UIColor.yellow, UIColor.white]
    
    let radar = SKSpriteNode()
    
    
    func setupForeground() {
        
        for i in 0..<numberOfForegrounds {
            let color2U = colours[i]
            let (texture, path) = buildGround(color: color2U)
            let foreground = BuildEntity(texture: texture, path: path, i: i, width: self.view!.bounds.width * 2)
            let scanground = BuildEntity(texture: texture, path: path, i: i, width: self.view!.bounds.width * 2)
            let foregroundNode = foreground.buildComponent.node
            let scanNode = scanground.buildComponent.node
            scanNode.delegate = self
            foregroundNode.delegate = self
            addChild(foreground.buildComponent.node)
            foregrounds.append(foreground.buildComponent.node)
            print("foreground.position.x \(foregroundNode.position.x)")
            scanNodes.append(scanNode)
        }
        // Add spaceman + aliens
        
        radar.position = CGPoint(x: self.view!.bounds.minX, y: self.view!.bounds.maxY * 2 - 256)
        radar.anchorPoint = CGPoint(x: 0.0, y: -1.0)
        addChild(radar)
        for scanNode in scanNodes {

            scanNode.scale(to: CGSize(width: scanNode.size.width/4, height: scanNode.size.height/4))
            scanNode.position.x = scanNode.position.x / 4
            radar.addChild(scanNode)
            
        }
        
    }
    
    func bebe() {
        for loop in 0...3 {
            let randY = GKRandomSource.sharedRandom().nextInt(upperBound: Int(self.view!.bounds.maxY - CGFloat(128))) + 128
            let randX = GKRandomSource.sharedRandom().nextInt(upperBound: Int(self.view!.bounds.maxX))
            let (bomberNode,bomberShadow) = addBomber(loop: 0, randX: CGFloat(randX), randY: CGFloat(randY))
            let link2D3 = linkedNodes(bodyA: bomberShadow, bodyB: bomberNode)
            self.links2F.append(link2D3)
        }
    }
    
    func dodo() {
        for loop in 0..<numberOfForegrounds {
            let randomSource = GKARC4RandomSource()
            let randomDistribution = GKRandomDistribution(randomSource: randomSource, lowestValue: 0, highestValue: 4)
            let randomValueT = Double(randomDistribution.nextInt())
            let waitAction = SKAction.wait(forDuration: randomValueT)
            let runAction = SKAction.run {
                let (spaceNode, randX) = self.addSpaceMen(loop: loop)
                let alienNode = self.addAlien(loop: loop, randX: randX)
                
                let sshadow = RescueEntity(imageName: "spaceMan", xCord: spaceNode.position.x, yCord: spaceNode.position.y)
                let spaceShadow = sshadow.rescueComponent.node
                spaceShadow.scale(to: CGSize(width: spaceShadow.size.width/4, height: spaceShadow.size.height/4))
                spaceShadow.delegate = self
                spaceShadow.zPosition = Layer.spaceman.rawValue
                spaceShadow.name = "spaceShadow"
                self.peoples.append(spaceShadow)
                self.scanNodes[loop].addChild(spaceShadow)
                spaceNode.userData = NSMutableDictionary()
                spaceNode.userData?.setObject(spaceShadow, forKey: "shadow" as NSCopying)
     
                let ashadow = AlienEntity(imageName: "alien", xCord: self.view!.bounds.maxX + randX, yCord: self.view!.bounds.maxY, screenBounds: self.view!.bounds)
                let alienShadow = ashadow.spriteComponent.node
                alienShadow.zPosition = Layer.alien.rawValue
                alienShadow.delegate = self
                alienShadow.name = "AlienShadow"
                alienShadow.zPosition = Layer.alien.rawValue
                self.scanNodes[loop].addChild(alienShadow)
                alienNode.userData = NSMutableDictionary()
                alienNode.userData?.setObject(alienShadow, forKey: "shadow" as NSCopying)
                
                let link2D = linkedNodes(bodyA: spaceNode, bodyB: spaceShadow)
                self.links2F.append(link2D)
                let link2D2 = linkedNodes(bodyA: alienNode, bodyB: alienShadow)
                self.links2F.append(link2D2)
            }
            foregrounds[loop].run(SKAction.sequence([waitAction,runAction]))
        }
//        let (bomberNode,bomberShadow) = addBomber(loop: 4, randX: self.view!.bounds.maxX, randY: 128)
//        let link2D3 = linkedNodes(bodyA: bomberShadow, bodyB: bomberNode)
//        self.links2F.append(link2D3)
    }
    
    func addBomber(loop: Int, randX: CGFloat, randY: CGFloat) -> (EntityNode, EntityNode) {
        let bomber = BomberEntity(imageName: "bomber", xCord: randX, yCord: randY, screenBounds: self.view!.bounds, view2D: foregrounds[0])
        let bomberNode = bomber.spriteComponent.node
        let bomberShadow = bomber.shadowComponent.node
        bomberNode.zPosition = Layer.alien.rawValue
        bomberNode.delegate = self
        
        bomberShadow.zPosition = Layer.alien.rawValue
        bomberShadow.delegate = self
        
//        foregrounds[loop].addChild(bomberNode)
        addChild(bomberNode)
        scanNodes[loop].addChild(bomberShadow)
//        addChild(bomberShadow)
        aliens.append(bomber)
        return (bomberNode,bomberShadow)
    }
    
    struct linkedNodes {
        var bodyA: EntityNode!
        var bodyB: EntityNode!
    }
    var links2F:[linkedNodes] = []
    
    func addSpaceMen(loop: Int) -> (EntityNode, CGFloat){
        let randomSource = GKARC4RandomSource()
        let randomDistribution = GKRandomDistribution(randomSource: randomSource, lowestValue: 0, highestValue: Int(self.view!.bounds.width))
        let randomValueX = CGFloat(randomDistribution.nextInt())
      
        let spaceMan = RescueEntity(imageName: "spaceMan", xCord: view!.bounds.maxX + randomValueX, yCord:view!.bounds.minY + 96)
        
        let spaceNode = spaceMan.rescueComponent.node
        spaceNode.delegate = self
        spaceNode.zPosition = Layer.spaceman.rawValue
        foregrounds[loop].addChild(spaceNode)
        
        return (spaceNode, randomValueX)
    }
    
    func addAlien(loop: Int, randX: CGFloat) -> EntityNode {
        let alien = AlienEntity(imageName: "alien", xCord: self.view!.bounds.maxX + randX, yCord: self.view!.bounds.maxY, screenBounds: self.view!.bounds)
        let alienNode = alien.spriteComponent.node
        alienNode.zPosition = Layer.alien.rawValue
        alienNode.delegate = self
        foregrounds[loop].addChild(alienNode)
        aliens.append(alien)
        return alienNode
    }
    
    var moveAmount: CGPoint!
//    var foregroundCGPoint: CGFloat!
    // broken
    
    func updateForegroundLeft() {
        self.enumerateChildNodes(withName: "foreground") { (node, stop) in
            if let foreground = node as? SKSpriteNode {
                self.moveAmount = CGPoint(x: -(self.groundSpeed * CGFloat(self.deltaTime)), y: self.playableStart)
                foreground.position.x += self.moveAmount.x
//                self.foregroundCGPoint = foreground.position.x
                
                if foreground.position.x < -foreground.size.width {
                    
                    if foreground.children.count > 0 {
                        print("disappear left")
                    }
                    
                    foreground.enumerateChildNodes(withName: "bomber", using: { (node, stop) in
                        if let bomber = node as? SKSpriteNode {
                            print("fuck bomber left \(bomber.position.x) \(foreground.position.x) \(foreground.size.width * CGFloat(self.numberOfForegrounds)) \(bomber.positionInScene)")
                
                            bomber.position.x += foreground.position.x
                            
                        }
                    })
                    foreground.position.x += foreground.size.width * CGFloat(self.numberOfForegrounds)
                    
                }
            }
        }
        self.updateScannerLeft(moveAmount: self.moveAmount.x)
    }
    
    func updateScannerLeft(moveAmount: CGFloat) {
        radar.enumerateChildNodes(withName: "foreground") { (node, stop) in
            if let foreground = node as? SKSpriteNode {
                foreground.position.x +=  moveAmount / CGFloat(4)

                if foreground.position.x < -(foreground.size.width) {
                    if foreground.children.count > 0 {
                        print("disappear right")
                    }
                    foreground.position.x += ((foreground.size.width * CGFloat(self.numberOfForegrounds)))
                    foreground.enumerateChildNodes(withName: "bomber", using: { (node, stop) in
//                        if let bomber = node as? SKSpriteNode {
//                            bomber.position.x += foreground.size.width * CGFloat(self.numberOfForegrounds)
//                        }
                        print("fuck bomber right")
                    })
                }
            }
        }
    }
    
    func updateForegroundRight() {
        self.enumerateChildNodes(withName: "foreground") { (node, stop) in
            if let foreground = node as? SKSpriteNode {
                self.moveAmount = CGPoint(x: -(self.groundSpeed * CGFloat(self.deltaTime)), y: self.playableStart)
                foreground.position.x -= self.moveAmount.x
//                self.foregroundCGPoint = foreground.position.x
                
                if foreground.position.x > foreground.size.width {
                    foreground.position.x -= foreground.size.width * CGFloat(self.numberOfForegrounds)
                }
            }
        }
        self.updateScannerRight(moveAmount: self.moveAmount.x)
    }
    
    func updateScannerRight(moveAmount: CGFloat) {
        radar.enumerateChildNodes(withName: "foreground") { (node, stop) in
            if let foreground = node as? SKSpriteNode {
                foreground.position.x -=  moveAmount / CGFloat(4)
                if foreground.position.x > (foreground.size.width * CGFloat(self.numberOfForegrounds - 1)) {
                    foreground.position.x -= ((foreground.size.width * CGFloat(self.numberOfForegrounds)))
                }
            }
        }
    }
    
    
    
    var playerNode: EntityNode!
    var shadowNode: EntityNode!
//    var advanceArrow: TouchableSprite!
    var advancedArrow: HeadsUpEntity!
    
    func setupPlayer(){
        player = PlayerEntity(imageName: "starship")
        playerNode = player.spriteComponent.node
        playerNode.position = CGPoint(x: self.view!.bounds.maxX / 2, y: self.view!.bounds.maxY / 2)
        playerNode.zPosition = Layer.player.rawValue
//        playerNode.size = CGSize(width: playerNode.size.width/4, height: playerNode.size.height/4)
        playerNode.delegate = self
        addChild(playerNode)
        
        shadow = PlayerEntity(imageName: "starship")
        shadowNode = shadow.spriteComponent.node
        shadowNode.position = CGPoint(x: self.view!.bounds.maxX / 2, y: self.view!.bounds.maxY / 2)
        shadowNode.scale(to: CGSize(width: shadowNode.size.width/4, height: shadowNode.size.height/4))
        shadowNode.position.x = shadowNode.position.x / 4
        radar.addChild(shadowNode)
        
        
//        player.movementComponent.playableStart = playableStart
        
        let upArrow = HeadsUpEntity(imageName: "UpArrow", xCord: (self.view?.bounds.minX)! + 128, yCord: ((self.view?.bounds.maxY)!) + 96, name: "up")
        upArrow.hudComponent.node.delegate = self

        let downArrow = HeadsUpEntity(imageName: "DownArrow", xCord: (self.view?.bounds.minX)! + 128, yCord: ((self.view?.bounds.maxY)!) - 96, name: "down")
        downArrow.hudComponent.node.delegate = self
        
        advancedArrow = HeadsUpEntity(imageName: "RightArrow", xCord: ((self.view?.bounds.maxX)! * 2) - 128, yCord: ((self.view?.bounds.maxY)!) - 128, name: "advance")
        advancedArrow.hudComponent.node.delegate = self
        
        let stopSquare = HeadsUpEntity(imageName: "Square", xCord: (self.view?.bounds.minX)! + 128, yCord: ((self.view?.bounds.maxY)!), name: "square")
        stopSquare.hudComponent.node.delegate = self
        
        let fireSquare = HeadsUpEntity(imageName: "Circle", xCord: ((self.view?.bounds.maxX)! * 2) - 128, yCord: ((self.view?.bounds.maxY)!), name: "fire")
        fireSquare.hudComponent.node.delegate = self
        
        let flipButton = HeadsUpEntity(imageName: "DoubleArrow", xCord: ((self.view?.bounds.maxX)! * 2) - 128, yCord: ((self.view?.bounds.maxY)!) + 160, name: "flip")
        flipButton.hudComponent.node.delegate = self
        
        
        addChild(upArrow.hudComponent.node)
        addChild(downArrow.hudComponent.node)
        addChild(stopSquare.hudComponent.node)
        addChild(advancedArrow.hudComponent.node)

        addChild(fireSquare.hudComponent.node)
        addChild(flipButton.hudComponent.node)
        
        
    }
    
    var cameraNode: SKCameraNode!
    
    
    override func didMove(to view: SKView) {
        /* Setup your scene here */
        physicsWorld.gravity = CGVector(dx: 0, dy: -0.5)
        physicsWorld.contactDelegate = self
        
        cameraNode = SKCameraNode()
        cameraNode.position = CGPoint(x: self.view!.bounds.maxX, y: self.view!.bounds.maxY)
        scene?.camera = cameraNode

        cameraNode.setScale(1)

        addChild(cameraNode)
        
        setupForeground()
        setupPlayer()
//        dodo()
        bebe()
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
        for alien in aliens {
            alien.update(deltaTime: deltaTime)
        }
        shadowNode.position.x = playerNode.position.x / 4
        shadowNode.position.y = playerNode.position.y / 4
        
        
        
        for link in links2F {
            link.bodyB.position.x = link.bodyA.position.x
            link.bodyB.position.y = link.bodyA.position.y
        }
        
    }
    
    func lowerSpeed() {
        if groundSpeed > 150 {
            groundSpeed = groundSpeed - 0.1
        } else {
            groundSpeed = 150
        }
    }
    
    func moreBreak() {
        if groundSpeed > 150 {
            groundSpeed = groundSpeed / 2
        }
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
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("ended")
    }
    
//    var pickup: CGPoint!
    
    var playerCG: CGFloat!
    
    func didBegin(_ contact: SKPhysicsContact) {
        let other = contact.bodyA.categoryBitMask == PhysicsCat.Player ? contact.bodyB : contact.bodyA
        let kidnap = contact.bodyA.categoryBitMask == PhysicsCat.Alien ? contact.bodyB : contact.bodyA
        let hit = contact.bodyA.categoryBitMask == PhysicsCat.Fire ? contact.bodyB : contact.bodyA
        
        // alien kidnaps spaceman

        if kidnap.node?.name == "spaceman" && kidnap.node?.parent?.name == "foreground" && contact.bodyB.node!.name == "alien" {
            print("rule I")
//            pickup = other.node?.position

            let shadow = kidnap.node?.userData?.object(forKey:"shadow") as! SKSpriteNode
            (shadow as? SKSpriteNode)?.removeFromParent()
            
            kidnap.node?.removeFromParent()
            kidnap.node?.position = CGPoint(x: 0, y: -96)
            contact.bodyB.node?.addChild(kidnap.node!)
            let alienShadow = contact.bodyB.node?.userData?.object(forKey:"shadow") as! SKSpriteNode
            alienShadow.addChild(shadow)
            return
        }
        
        // drop spaceman if ground touches him
        
        if other.node?.name == "spaceman" && other.node?.parent?.name == "foreground" && contact.bodyB.node!.name == "starship" {
//        if other.node?.name == "spaceman" && contact.bodyB.node!.name == "starship" {
            print("rule II")
//            pickup = other.node?.position
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
            
            let alienShadow = hit.node?.userData?.object(forKey:"shadow") as! SKSpriteNode
            alienShadow.removeFromParent()
            contact.bodyA.node?.removeFromParent()
            
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
        
        // fire hits bomber
        if hit.node?.name == "bomber" {
            let bomberShadow = hit.node?.userData?.object(forKey:"shadow") as! SKSpriteNode
            bomberShadow.removeFromParent()
            hit.node?.removeFromParent()
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
        
        case "bomber":
            print("bomber.position \(box.position)")
        case "starship":
            print("playerNode.position \(playerNode.position)")
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
                groundSpeed += 150
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
                advancedArrow.hudComponent.changeTexture(imageNamed: "RightArrow")
                // moveRight/moveLet control the background direction
                moveLeft = true
                moveRight = false
                player.movementComponent.applyImpulseLeft(lastUpdateTimeInterval)
                shadow.movementComponent.leftTexture()
            case "right":
                advancedArrow.hudComponent.changeTexture(imageNamed: "LeftArrow")
                moveRight = true
                moveLeft = false
                player.movementComponent.applyImpulseRight(lastUpdateTimeInterval)
                shadow.movementComponent.rightTexture()
            default:
                break
            }
        case "fire":
            let mshape = CGRect(x: 0, y: 0, width: 24, height: 6)
            let missileX = FireEntity(rect: mshape, xCord: 0, yCord: 0)
            
            let fireNode = missileX.shapeComponent.node
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
            print("print \(box.name) \(box.position)")
            player.movementComponent.applyZero(lastUpdateTimeInterval)
//            moreBreak()
            
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

extension SKNode {
    var positionInScene:CGPoint? {
        if let scene = scene, let parent = parent {
            return parent.convert(position, to:scene)
        } else {
            return nil
        }
    }
}
