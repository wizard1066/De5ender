//
//  GameScene.swift
//  SKDefender
//
//  Created by localadmin on 06.11.18.
//  Copyright © 2018 ch.cqd.skdefender. All rights reserved.
// 024860

import SpriteKit
import GameplayKit
import CoreMotion
import AVFoundation

struct PhysicsCat {
    static let None: UInt32 = 0
    static let Player: UInt32 = 0b1
    static let Ground: UInt32 = 0b1 << 1
    static let Fire: UInt32 = 0b1 << 2
    static let SpaceMan: UInt32 = 0b1 << 3
    static let Alien: UInt32 = 0b1 << 4
    static let Bomber: UInt32 = 0b1 << 5
    static let Mine: UInt32 = 0b1 << 6
}

enum status {
    case untouched
    case kidnapped
    case rescued
}

enum spriteAttack {
    case cominNorth
    case cominSouth
    case cominEast
    case cominWest
}

class GameScene: SKScene, SKPhysicsContactDelegate, touchMe, landerEscaped {
    
    var lives: Int = 3
    
    var moveLeft = false
    var moveRight = false
    
    // Higher values, further back, mask top level here
    
    enum Layer: CGFloat {
        case background
        case foreground
        case player
        case spaceman
        case alien
        case controls
        case mask
    }
    
    var player:PlayerEntity!
    var shadow:PlayerEntity!
    var bodyCount:Int = 0 {
        didSet {
            newLunch()
        }
    }
    
    var playableStart: CGFloat = 0
    
    var deltaTime: TimeInterval = 0
    var lastUpdateTimeInterval: TimeInterval = 0
    
    let numberOfForegrounds = 8
    var groundSpeed:CGFloat = 150
    var brakeSpeed:CGFloat = 0.1
    
    lazy var screenWidth = view!.bounds.width
    lazy var screenHeight = view!.bounds.height
    
    
    
    var firing: AVAudioPlayer!
    var lastEscape: EntityNode!
    
    func spriteEscaped(sprite: EntityNode) {
        if lastEscape == sprite {
            return
        } else {
            lastEscape = sprite
        }
        doBodyCount()
    }
    
    func preLoadSound() {
        do {
            let path = Bundle.main.path(forResource: "science_fiction_laser_007", ofType: ("mp3"))
            let url = URL(fileURLWithPath: path!)
            firing = try! AVAudioPlayer(contentsOf: url)
            firing.prepareToPlay
        }
    }
    
    var lastValue: CGFloat = 96
    var firstValue: CGFloat = 0
    
    // 128 here is a multiple of the screen width
    func buildGround(color: UIColor, lastOne: Int) -> (SKTexture, CGMutablePath) {
        print("lastOne \(lastOne)")
        let loopsNeeded = Int(screenWidth / 16)
        var path: CGMutablePath?
        let randomSource = GKARC4RandomSource()
        let randomDistribution = GKRandomDistribution(randomSource: randomSource, lowestValue: 80, highestValue: 256)
        for loop in stride(from: 0, to: Int(screenWidth*2), by: loopsNeeded) {
            var randomValueY = randomDistribution.nextInt()
            if lastOne == numberOfForegrounds - 1, loop == Int(screenWidth*2) {
                randomValueY = 96
            }
            if path == nil {
                path = CGMutablePath()
                path!.move(to: CGPoint(x: firstValue, y: lastValue))
            } else {
                path!.addLine(to: CGPoint(x: loop, y: randomValueY))
            }
            lastValue = CGFloat(randomValueY)
            
        }
        
        let shape = SKShapeNode()
        shape.path = path
        shape.strokeColor = color
        shape.lineWidth = 2
        shape.zPosition = 1
        
        let texture = view?.texture(from: shape)
        
        
        return (texture!,path!)
    }
   
    var foregrounds:[EntityNode] = []
    var scanNodes:[EntityNode] = []
    var colours = [UIColor.red, UIColor.blue, UIColor.green, UIColor.magenta, UIColor.purple, UIColor.orange, UIColor.yellow, UIColor.white, UIColor.brown]
    
    let radar = SKSpriteNode()
    let radarScenes:CGFloat = 4
    let baseCamp = 128
    
    func setupForeground() {
        
        for i in 0..<numberOfForegrounds {
            let color2U = colours[i]
            let (texture, path) = buildGround(color: color2U, lastOne: i)
            let foreground = BuildEntity(texture: texture, path: path, i: i, width: self.view!.bounds.width * 2, physics: true)
            let scanground = BuildEntity(texture: texture, path: path, i: i, width: self.view!.bounds.width * 2, physics: false)
            let foregroundNode = foreground.buildComponent.node
            let scanNode = scanground.buildComponent.node
            scanNode.delegate = self
            foregroundNode.delegate = self
//            staticStars(source: foregroundNode)
            addChild(foreground.buildComponent.node)
            foregrounds.append(foregroundNode)
            scanNodes.append(scanNode)
        }
        
        // add a mother spritenode to add all the scanner nodes too
        radar.position = CGPoint(x: self.view!.bounds.maxX / 2, y: self.view!.bounds.maxY * 2 - self.view!.bounds.maxY * 0.4)
        radar.anchorPoint = CGPoint(x: 0.0, y: -1.0)
        
        addChild(radar)
        for scanNode in scanNodes {
            scanNode.scale(to: CGSize(width: scanNode.size.width/radarScenes, height: scanNode.size.height/radarScenes))
            scanNode.position.x = scanNode.position.x / radarScenes
            radar.addChild(scanNode)
        }
        
//        let block = SKShapeNode(rect: CGRect(x: self.view!.bounds.minX, y: self.view!.bounds.maxY * 2 - self.view!.bounds.maxY * 0.4, width: self.view!.bounds.maxX/2, height:self.view!.bounds.maxY * 0.4 / 2))
//        block.fillColor = (scene?.backgroundColor)!
//        block.lineWidth = 0
//        block.zPosition = Layer.mask.rawValue
//        addChild(block)
//
//        let block2 = SKShapeNode(rect: CGRect(x: self.view!.bounds.minX + self.view!.bounds.maxX/2 * 3, y: self.view!.bounds.maxY * 2 - self.view!.bounds.maxY * 0.4, width: self.view!.bounds.maxX/2, height:self.view!.bounds.maxY * 0.4 / 2))
//        block2.fillColor = (scene?.backgroundColor)!
//        block2.lineWidth = 0
//        block2.zPosition = Layer.mask.rawValue
//        addChild(block2)
        
    }
    
    func doBaiters(sceneNo: Int, player: PlayerEntity, bodies: Int) {
        print("doBaiters")
        let randomSource = GKARC4RandomSource()
        let randomDistribution = GKRandomDistribution(randomSource: randomSource, lowestValue: 4, highestValue: numberOfForegrounds - 1)
        for _ in 0..<bodies {
//            let randomValueZ = randomDistribution.nextInt()
            let radar = self.view!.bounds.maxY * 0.3
            let randY = CGFloat(GKRandomSource.sharedRandom().nextInt(upperBound: Int(self.view!.bounds.maxY * 2 - radar)))
            let randX = CGFloat(GKRandomSource.sharedRandom().nextInt(upperBound: Int(self.view!.bounds.maxX * 2)))
            let (baiterNode, baiterShdow) = addBaiter(sceneNo: sceneNo,randX: randX, randY: randY, player: player)
        }
    }
    
    func doMutants(sceneNo: Int, player: PlayerEntity, bodies: Int) {
        print("doMutants")
        let randomSource = GKARC4RandomSource()
        let randomDistribution = GKRandomDistribution(randomSource: randomSource, lowestValue: 4, highestValue: numberOfForegrounds - 1)
        for loop in 0..<bodies {
            let randomValueZ = randomDistribution.nextInt()
            let radar = self.view!.bounds.maxY * 0.3
            let randY = CGFloat(GKRandomSource.sharedRandom().nextInt(upperBound: Int(self.view!.bounds.maxY * 2 - radar)))
            let randX = CGFloat(GKRandomSource.sharedRandom().nextInt(upperBound: Int(self.view!.bounds.maxX * 2)))
            let (mutantNode, mutantShadow) = addMutant(sceneNo: sceneNo, randX: randX, randY: randY, player: player)
        }
    }
    
    func doBombers(sceneNo: Int, bodies: Int, wayToGo: spriteAttack) {
        print("doBombers")
        for loop in 0..<bodies {
            let randY = GKRandomSource.sharedRandom().nextInt(upperBound: Int(self.view!.bounds.maxY - CGFloat(baseCamp)))
            let randX = GKRandomSource.sharedRandom().nextInt(upperBound: Int(self.view!.bounds.maxX * 2))
            let (bomberNode, bomberShadow) = addBomber(sceneNo: sceneNo, randX: CGFloat(randX), randY: CGFloat(randY), scanNodes: scanNodes, foregrounds: foregrounds, direction: wayToGo)
        }
    }
    
    func doLanders(sceneNo: Int, player: PlayerEntity, bodies: Int) {
//        print("doLanders")
//        let randomSource = GKARC4RandomSource()
//        let randomDistribution = GKRandomDistribution(randomSource: randomSource, lowestValue: 4, highestValue: numberOfForegrounds - 1)
        for loop in 0..<bodies {
//            let randomValueZ = randomDistribution.nextInt()
            let randT = CGFloat(GKRandomSource.sharedRandom().nextInt(upperBound: 8))
            let waitAction = SKAction.wait(forDuration: TimeInterval(randT))
            let execAction = SKAction.run {
                let randX = CGFloat(GKRandomSource.sharedRandom().nextInt(upperBound: Int(self.view!.bounds.maxX * 2)))
                let (landerNode,_) = self.addLander(sceneNo: sceneNo, randX: randX, randY: (self.view?.bounds.maxY)!*2, player: player)
                let (itemNode,_) = self.addItem(sceneNo: sceneNo, randX: randX)
            }
            player.spriteComponent.node.run(SKAction.sequence([waitAction, execAction]))
        }
    }
    
    var landers:[LanderEntity] = []
    
    func addItem(sceneNo: Int, randX: CGFloat) -> (EntityNode, EntityNode) {
        let shadow = ItemEntity(imageName: "ItemBlank", xCord: randX, yCord: self.view!.bounds.minY + 96, shadowNode: nil)
        let itemShadow = shadow.itemComponent.node
        itemShadow.delegate = self
        itemShadow.name = "shadow"
        itemShadow.zPosition = Layer.spaceman.rawValue
        
        let item = ItemEntity(imageName: "ItemBlank", xCord: randX, yCord: self.view!.bounds.minY + 96, shadowNode: itemShadow)
        let itemNode = item.itemComponent.node
        itemNode.zPosition = Layer.spaceman.rawValue
        itemNode.delegate = self
        scanNodes[sceneNo].addChild(itemShadow)
        foregrounds[sceneNo].addChild(itemNode)
        
        return (itemNode, itemShadow)
    }
    
    func addLander(sceneNo: Int, randX: CGFloat, randY: CGFloat, player: PlayerEntity) -> (EntityNode, EntityNode) {
        let shadow = LanderEntity(imageName: "alien", xCord: randX, yCord: self.view!.bounds.maxY, screenBounds: self.view!.bounds, shadowNode: nil)
        shadow.landerComponent.setVariables(foregrounds: foregrounds, playerNode: playerNode, sceneNo: sceneNo)
        shadow.landerComponent.delegate = self
        let landerShadow = shadow.spriteComponent.node
        landerShadow.zPosition = Layer.alien.rawValue
        landerShadow.delegate = self
        landerShadow.name = "shadow"
        landerShadow.zPosition = Layer.alien.rawValue
        
        
        let lander = LanderEntity(imageName: "alien", xCord: randX, yCord: self.view!.bounds.maxY, screenBounds: self.view!.bounds, shadowNode: landerShadow)
        lander.landerComponent.setVariables(foregrounds: foregrounds, playerNode: playerNode, sceneNo: sceneNo)
        lander.landerComponent.delegate = self
        let landerNode = lander.spriteComponent.node
        landerNode.zPosition = Layer.alien.rawValue
        landerNode.delegate = self
        scanNodes[sceneNo].addChild(landerShadow)
        foregrounds[sceneNo].addChild(landerNode)
        landers.append(lander)
      
        return (landerNode, landerShadow)
    }
    
    var baiters:[BaiterEntity] = []
    
    func addBaiter(sceneNo: Int,randX: CGFloat, randY: CGFloat, player: PlayerEntity) -> (EntityNode, EntityNode) {
        let shadow = BaiterEntity(imageName: "baiter", xCord: randX, yCord: randY, screenBounds: self.view!.bounds, view2D: foregrounds[0], scanNodes:scanNodes, foregrounds:foregrounds, shadowNode: nil, playerToKill: nil)
        let baiterShadow = shadow.spriteComponent.node
        shadow.baiterComponent.setScene(sceneNo: sceneNo)
        switch sceneNo {
        case 0:
            shadow.baiterComponent.setRunning(value2D: .cominNorth)
            break
        case 1:
            shadow.baiterComponent.setRunning(value2D: .cominSouth)
            break
        case 2:
            shadow.baiterComponent.setRunning(value2D: .cominEast)
            break
        default:
            shadow.baiterComponent.setRunning(value2D: .cominWest)
        }
    
        baiterShadow.zPosition = Layer.alien.rawValue
        baiterShadow.delegate = self
        
        let baiter = BaiterEntity(imageName: "baiter", xCord: randX, yCord: randY, screenBounds: self.view!.bounds, view2D: foregrounds[0], scanNodes:scanNodes, foregrounds:foregrounds, shadowNode: baiterShadow, playerToKill: player)
        let baiterNode = baiter.spriteComponent.node
        baiter.baiterComponent.setScene(sceneNo: sceneNo)
        switch sceneNo {
        case 0:
            baiter.baiterComponent.setRunning(value2D: .cominNorth)
            break
        case 1:
            baiter.baiterComponent.setRunning(value2D: .cominSouth)
            break
        case 2:
            baiter.baiterComponent.setRunning(value2D: .cominEast)
            break
        default:
            baiter.baiterComponent.setRunning(value2D: .cominWest)
        }
        baiterNode.zPosition = Layer.alien.rawValue
        baiterNode.delegate = self
        
        foregrounds[sceneNo].addChild(baiterNode)
        scanNodes[sceneNo].addChild(baiterShadow)
        baiters.append(baiter)
        
        return (baiterNode, baiterShadow)
    }
    
    var mutants:[MutantEntity] = []
    
    func addMutant(sceneNo: Int, randX: CGFloat, randY: CGFloat, player: PlayerEntity) -> (EntityNode, EntityNode) {
        
        let shadow = MutantEntity(imageName: "mutant", xCord: randX, yCord: randY, screenBounds: self.view!.bounds, view2D: foregrounds[0], scanNodes:scanNodes, foregrounds:foregrounds, shadowNode: nil, playerToKill: nil)
        let mutantShadow = shadow.spriteComponent.node
        shadow.mutantComponent.setScene(sceneNo: sceneNo)
        if sceneNo % 2 == 0 {
            shadow.mutantComponent.setRunning(value2D: .cominNorth)
        } else {
            shadow.mutantComponent.setRunning(value2D: .cominSouth)
        }
        mutantShadow.zPosition = Layer.alien.rawValue
        mutantShadow.delegate = self
        
        let mutant = MutantEntity(imageName: "mutant", xCord: randX, yCord: randY, screenBounds: self.view!.bounds, view2D: foregrounds[0], scanNodes:scanNodes, foregrounds:foregrounds, shadowNode: mutantShadow, playerToKill: player)
        let mutantNode = mutant.spriteComponent.node
        mutant.mutantComponent.setScene(sceneNo: sceneNo)
        if sceneNo % 2 == 0 {
            mutant.mutantComponent.setRunning(value2D: .cominNorth)
        } else {
            mutant.mutantComponent.setRunning(value2D: .cominSouth)
        }
        mutantNode.zPosition = Layer.alien.rawValue
        mutantNode.delegate = self
        
        mutant.mutantComponent.setScreen(entity: foregrounds[0])
        
        foregrounds[sceneNo].addChild(mutantNode)
        scanNodes[sceneNo].addChild(mutantShadow)
        mutants.append(mutant)
        
        return (mutantNode, mutantShadow)
    }
    
    var bombers:[BomberEntity] = []
    
    func addBomber(sceneNo: Int, randX: CGFloat, randY: CGFloat, scanNodes:[EntityNode], foregrounds:[EntityNode], direction: spriteAttack) -> (EntityNode, EntityNode) {
        var imageName: String!
        if direction == .cominWest {
            imageName = "bomberb"
        } else {
            imageName = "bomber"
        }
        let shadow = BomberEntity(imageName: imageName, xCord: randX, yCord: randY, screenBounds: self.view!.bounds, view2D: foregrounds[0], scanNodes:scanNodes, foregrounds:foregrounds, shadowNode: nil)
        shadow.bomberComponent.setVariable(sceneNo: sceneNo, direction: direction)
        let bomberShadow = shadow.spriteComponent.node
        bomberShadow.zPosition = Layer.alien.rawValue
        bomberShadow.delegate = self
        
        let bomber = BomberEntity(imageName: imageName, xCord: randX, yCord: randY, screenBounds: self.view!.bounds, view2D: foregrounds[0], scanNodes:scanNodes, foregrounds:foregrounds, shadowNode: bomberShadow)
        bomber.bomberComponent.setVariable(sceneNo: sceneNo, direction: direction)
        let bomberNode = bomber.spriteComponent.node
        bomberNode.zPosition = Layer.alien.rawValue
        bomberNode.delegate = self
        
        foregrounds[sceneNo].addChild(bomberNode)
        scanNodes[sceneNo].addChild(bomberShadow)
        bombers.append(bomber)
        
        return (bomberNode, bomberShadow)
    }
    
    var moveAmount: CGPoint!
    
    func updateForegroundLeft() {
        self.enumerateChildNodes(withName: "foreground") { (node, stop) in
            if let foreground = node as? SKSpriteNode {
                self.moveAmount = CGPoint(x: -(self.groundSpeed * CGFloat(self.deltaTime)), y: self.playableStart)
                foreground.position.x += self.moveAmount.x
                
                if foreground.position.x < -foreground.size.width * 3 {
                    foreground.position.x += foreground.size.width * CGFloat(self.numberOfForegrounds)
                    
                }
            }
        }
        self.updateScannerLeft(moveAmount: self.moveAmount.x)
    }
    
    func updateScannerLeft(moveAmount: CGFloat) {
        radar.enumerateChildNodes(withName: "foreground") { (node, stop) in
            if let foreground = node as? SKSpriteNode {
                foreground.position.x +=  moveAmount / self.radarScenes

                if foreground.position.x < -(foreground.size.width * 3) {
                    foreground.position.x += ((foreground.size.width * CGFloat(self.numberOfForegrounds)))
                }
            }
        }
    }
    
    func updateForegroundRight() {
        self.enumerateChildNodes(withName: "foreground") { (node, stop) in
            if let foreground = node as? SKSpriteNode {
                self.moveAmount = CGPoint(x: -(self.groundSpeed * CGFloat(self.deltaTime)), y: self.playableStart)
                foreground.position.x -= self.moveAmount.x
                
                if foreground.position.x > foreground.size.width * 3 {
                    foreground.position.x -= foreground.size.width * CGFloat(self.numberOfForegrounds)
                }
            }
        }
        self.updateScannerRight(moveAmount: self.moveAmount.x)
    }
    
    func updateScannerRight(moveAmount: CGFloat) {
        radar.enumerateChildNodes(withName: "foreground") { (node, stop) in
            if let foreground = node as? SKSpriteNode {
                foreground.position.x -=  moveAmount / self.radarScenes
                if foreground.position.x > (foreground.size.width * CGFloat(self.numberOfForegrounds - 3)) {
                    foreground.position.x -= ((foreground.size.width * CGFloat(self.numberOfForegrounds)))
                }
            }
        }
    }
    
    
    
    var playerNode: EntityNode!
    var shadowNode: EntityNode!
    var advancedArrow: HeadsUpEntity!
    var highScore: TextEntity!
    var nextWave: TextEntity!
    var playerLives:[EntityNode] = []
    
    func showLives() {
        for lifes in 0...lives - 1 {
            let playerAvailable = PlayerEntity(imageName: "ship16", shadowNode: nil, physics: false)
            let playerAvailableNode = playerAvailable.spriteComponent.node
            playerAvailableNode.position = CGPoint(x: self.view!.bounds.minX + CGFloat(64), y: (self.view!.bounds.maxY * 2) - CGFloat((lifes * 64) + 64))
            playerAvailableNode.scale(to: CGSize(width: playerAvailableNode.size.width/2.5, height: playerAvailableNode.size.height/2.5))
            addChild(playerAvailableNode)
            playerLives.append(playerAvailableNode)
        }
    }
    
    func removeLives() {
        if playerLives.count > 0 {
            let playerToGo = playerLives.popLast() as? EntityNode
            playerToGo!.removeFromParent()
        }
    }
    
    func addPlayer() {
        
        shadow = PlayerEntity(imageName: "ship16", shadowNode: nil, physics: false)
        shadowNode = shadow.spriteComponent.node
        shadowNode.position = CGPoint(x: self.view!.bounds.maxX / 2, y: self.view!.bounds.maxY / 2)
        shadowNode.scale(to: CGSize(width: shadowNode.size.width/4, height: shadowNode.size.height/4))
        shadowNode.position.x = shadowNode.position.x / 4
        radar.addChild(shadowNode)
        
        player = PlayerEntity(imageName: "ship16", shadowNode: shadowNode, physics: true)
        playerNode = player.spriteComponent.node
        playerNode.position = CGPoint(x: self.view!.bounds.maxX / 2, y: self.view!.bounds.maxY / 2)
        playerNode.zPosition = Layer.player.rawValue
        playerNode.delegate = self
        addChild(playerNode)
    
    }
    
    func addHUD() {
        let upArrow = HeadsUpEntity(imageName: "UpArrow", xCord: (self.view?.bounds.minX)! + 128, yCord: ((self.view?.bounds.maxY)!) + 128, name: "up")
        upArrow.hudComponent.node.delegate = self
         upArrow.hudComponent.node.zPosition = Layer.controls.rawValue

        let downArrow = HeadsUpEntity(imageName: "DownArrow", xCord: (self.view?.bounds.minX)! + 128, yCord: ((self.view?.bounds.maxY)!) - 128, name: "down")
        downArrow.hudComponent.node.delegate = self
         downArrow.hudComponent.node.zPosition = Layer.controls.rawValue
        
        advancedArrow = HeadsUpEntity(imageName: "RightArrow", xCord: ((self.view?.bounds.maxX)! * 2) - 128, yCord: ((self.view?.bounds.maxY)!) - 160, name: "advance")
        advancedArrow.hudComponent.node.delegate = self
         advancedArrow.hudComponent.node.zPosition = Layer.controls.rawValue
        
        let stopSquare = HeadsUpEntity(imageName: "Square", xCord: (self.view?.bounds.minX)! + 128, yCord: ((self.view?.bounds.maxY)!), name: "square")
        stopSquare.hudComponent.node.delegate = self
         stopSquare.hudComponent.node.zPosition = Layer.controls.rawValue
        
        let fireSquare = HeadsUpEntity(imageName: "Circle", xCord: ((self.view?.bounds.maxX)! * 2) - 128, yCord: ((self.view?.bounds.maxY)!), name: "fire")
        fireSquare.hudComponent.node.delegate = self
        fireSquare.hudComponent.node.zPosition = Layer.controls.rawValue
        
        let flipButton = HeadsUpEntity(imageName: "DoubleArrow", xCord: ((self.view?.bounds.maxX)! * 2) - 128, yCord: ((self.view?.bounds.maxY)!) + 160, name: "flip")
        flipButton.hudComponent.node.delegate = self
        flipButton.hudComponent.node.zPosition = Layer.controls.rawValue
        
        
        addChild(upArrow.hudComponent.node)
        addChild(downArrow.hudComponent.node)
        addChild(stopSquare.hudComponent.node)
        addChild(advancedArrow.hudComponent.node)

        addChild(fireSquare.hudComponent.node)
        addChild(flipButton.hudComponent.node)
        
        
    }
    
    var cameraNode: SKCameraNode!
    var manager: CMMotionManager!
    
    func staticStars(source: SKSpriteNode) {
        let lowest = Int(self.view!.bounds.maxY * 0.2)
        for k in lowest ... Int(self.view!.bounds.maxY * 2 * 0.8) {
            let place = GKRandomSource.sharedRandom().nextBool()
            if place {
                let randX = GKRandomSource.sharedRandom().nextInt(upperBound: Int(self.view!.bounds.maxX) * 2)
                let star = SKLabelNode(fontNamed: "Helvetica")
                let randP = GKRandomSource.sharedRandom().nextInt(upperBound: 18) - 8
                if randP > 6 {
                    star.fontSize = CGFloat(randP)
                    star.text = "✦"
                    star.position = CGPoint(x: randX, y: k)
                    source.addChild(star)
                }
            }
        }
        
    }
    
    override func didMove(to view: SKView) {
        /* Setup your scene here */
        physicsWorld.gravity = CGVector(dx: 0, dy: -0.5)
        physicsWorld.contactDelegate = self
        
        manager = CMMotionManager()
        guard manager.isAccelerometerAvailable else {
            print("no manager")
            return
        }
        
//        manager.startDeviceMotionUpdates()
        
        preLoadSound()
        
        cameraNode = SKCameraNode()
        cameraNode.position = CGPoint(x: self.view!.bounds.maxX, y: self.view!.bounds.maxY)
        scene?.camera = cameraNode

        cameraNode.setScale(1)

        addChild(cameraNode)
        
        setupForeground()
        showLives()
        addPlayer()
        addHUD()
        
//        Add a boundry to the screen
        let rectToSecure = CGRect(x: 0, y: 0, width: self.view!.bounds.maxX * 2, height: self.view!.bounds.minY * 2 )
        physicsBody = SKPhysicsBody(edgeLoopFrom: rectToSecure)
        physicsBody?.isDynamic = false

        let highscorePlacement = CGPoint(x: self.view!.bounds.maxX * 2 - 128, y: self.view!.bounds.maxY * 2 - 128)
        highScore = TextEntity(text: "0", Cords:highscorePlacement , name: "highscore")
        addChild(highScore.textComponent.node)
        
        let nextWavePlacement = CGPoint(x: self.view!.bounds.maxX, y: self.view!.bounds.maxY)
        nextWave = TextEntity(text: "", Cords: nextWavePlacement, name: "nextwave")
        addChild(nextWave.textComponent.node)

        newWave()
        flipMe()
    }
    
    // Runs when I change the value held in bodyCount
    func newLunch() {
//        nextWave.textComponent.node.run(SKAction.fadeOut(withDuration: 2))
        if bodyCount == 0 {
            let waitAction = SKAction.wait(forDuration: 4)
//            let fadeAction = SKAction.fadeIn(withDuration: 2)
            let newAction = SKAction.run {
                self.nextWave.textComponent.node.run(SKAction.fadeIn(withDuration: 4))
                self.waveCount += 1
                self.newWave()
                print("\(self.waveCount)")
            }
            nextWave.textComponent.node.run(SKAction.sequence([newAction]))
        }
    }
    
    func flipMe() {
        advancedArrow.hudComponent.changeTexture(imageNamed: "LeftArrow")
        moveRight = true
        moveLeft = false
        player.movementComponent.setScreen(entity: scene!)
        player.movementComponent.applyImpulseRight(lastUpdateTimeInterval)
        radar.position = CGPoint(x: self.view!.bounds.maxX, y: self.view!.bounds.maxY * 2 - self.view!.bounds.maxY * 0.4)
    }
    
    var waveCount = 1
    
    func newWave() {
        bodyCount = 7 + (8 * waveCount)
//        bodyCount = (2 * waveCount)
        
        nextWave.textComponent.node.text = "Wave \(waveCount)"
        let waitAction = SKAction.wait(forDuration: 4)
        let fadeOutAction = SKAction.fadeOut(withDuration: 4)
        nextWave.textComponent.node.run(SKAction.sequence([waitAction, fadeOutAction]))

        let playerScene = whereIsPlayer()
        let randomValueZ = (playerScene + 4) % numberOfForegrounds
        
//        doBombers(sceneNo: randomValueZ,bodies: 2 * waveCount, wayToGo: .cominEast) // 2 bombers
//        doBombers(sceneNo: randomValueZ,bodies: 2 * waveCount, wayToGo: .cominWest) // 2 bombers

//        doBaiters(sceneNo: 3,player: player, bodies: 2 * waveCount) // 4 baiters memory ok
//        doBaiters(sceneNo: 5,player: player, bodies: 2 * waveCount) // 4 baiters memory ok
        doMutants(sceneNo: 3,player: player, bodies: 2 * waveCount) // 4 mutants memory ok
        doMutants(sceneNo: 5,player: player, bodies: 2 * waveCount)

//        for sceneNo in 0...7 {
//            doLanders(sceneNo: sceneNo,player: player, bodies: 1)
//        }
        
        
    }
    
    public func whereIsPlayer() -> Int {
        var indexToReturn = 0
        for foreground in foregrounds {
            if playerNode.position.x < foreground.frame.minX || playerNode.position.x > foreground.frame.maxX {
                // do nothing
            } else {
                return indexToReturn
            }
            indexToReturn += 1
        }
        return indexToReturn
    }
    
    
    override func update(_ currentTime: CFTimeInterval) {
        let direct = manager.deviceMotion?.attitude
        if direct != nil {
            if direct!.pitch > 0.1 {
                moveRight = false
                moveLeft = true
                player.movementComponent.setScreen(entity: scene!)
                player.movementComponent.applyImpulseXb(lastUpdateTimeInterval)
                advancedArrow.hudComponent.changeTexture(imageNamed: "RightArrow")
                player.movementComponent.applyImpulseLeftX(lastUpdateTimeInterval)
            }
            if direct!.pitch < -0.1 {
                moveRight = true
                moveLeft = false
                player.movementComponent.setScreen(entity: scene!)
                player.movementComponent.applyImpulseXb(lastUpdateTimeInterval)
                advancedArrow.hudComponent.changeTexture(imageNamed: "LeftArrow")
                player.movementComponent.applyImpulseRightX(lastUpdateTimeInterval)
            }
            if direct!.roll > 0.1 {
                player.movementComponent.setScreen(entity: scene!)
                player.movementComponent.applyImpulseUpX(lastUpdateTimeInterval)
            }
            if direct!.roll < -0.1 {
                player.movementComponent.setScreen(entity: scene!)
                player.movementComponent.applyImpulseDownX(lastUpdateTimeInterval)
            }
        }
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

        shadowNode.position.x = playerNode.position.x / 4
        shadowNode.position.y = playerNode.position.y / 4
        
        for lander in landers {
            lander.update(deltaTime: deltaTime)
        }
        
        for bomber in bombers {
            bomber.update(deltaTime: deltaTime)
        }
        
        for mutant in mutants {
            mutant.update(deltaTime: deltaTime)
        }
        
        for baiter in baiters {
            baiter.update(deltaTime: deltaTime)
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
    
    var playerCG: CGFloat!
    var points: Int = 0
    
    func doBodyCount() {
        print("bodyCount \(bodyCount)")
        bodyCount -= 1
        if bodyCount == 0 {
            nextWave.textComponent.node.alpha = 0
            if nextWave.textComponent.node.parent == nil {
                addChild(nextWave.textComponent.node)
            }
            nextWave.textComponent.node.run(SKAction.fadeIn(withDuration: 2))
        }
    }
    
    var lastNodeA: SKNode!
    var lastNodeB: SKNode!

    
    func didBegin(_ contact: SKPhysicsContact) {
        // Stops multiple calls to didBegin same object, but brakes our spaceman drop
//            if lastNodeA == contact.bodyA.node || lastNodeB == contact.bodyB.node {
//                return
//            } else {
//                lastNodeA = contact.bodyA.node
//                lastNodeB = contact.bodyB.node
//            }
        
        
        let other = contact.bodyA.categoryBitMask == PhysicsCat.Player ? contact.bodyB : contact.bodyA
        let kidnap = contact.bodyA.categoryBitMask == PhysicsCat.Alien ? contact.bodyB : contact.bodyA
        let hit = contact.bodyA.categoryBitMask == PhysicsCat.Fire ? contact.bodyB : contact.bodyA

        
        // alien kidnaps spaceman

        if kidnap.node?.name == "spaceman" && kidnap.node?.parent?.name == "foreground" && contact.bodyA.node!.name == "alien" {
            if let node = kidnap.node as? SKSpriteNode {
                if node.parent != nil {
                    print("rule I")
                    let shadow = kidnap.node?.userData?.object(forKey:"shadow") as! SKSpriteNode
                    (shadow as? SKSpriteNode)?.removeFromParent()

                    kidnap.node?.removeFromParent()
                    kidnap.node?.position = CGPoint(x: 0, y: -96)
                    kidnap.node?.userData?.setObject(status.kidnapped, forKey: "status" as NSCopying)
                    contact.bodyA.node?.addChild(kidnap.node!)
                    let alienShadow = contact.bodyA.node?.userData?.object(forKey:"shadow") as! SKSpriteNode
                    alienShadow.position = CGPoint(x: 0, y: -64)
                    alienShadow.addChild(shadow)
                    highScore.textComponent.lessScore(score: 100)
                }
            }
            return
        }

        // pickup falling spaceman from lander

        if other.node?.name == "spaceman" && other.node?.parent?.name == "foreground" && contact.bodyB.node!.name == "starship"  {
            //        if other.node?.name == "spaceman" && contact.bodyB.node!.name == "starship" {
            if let node = hit.node as? SKSpriteNode {
                if node.parent != nil {
                    print("rule II")
                    //            pickup = other.node?.position
                    if other.node?.userData?.object(forKey: "status") as? status == status.kidnapped {
                        
                        let positionToScore = CGPoint(x: playerNode.position.x , y: playerNode.position.y - 64)
                        other.node?.removeFromParent()
                        other.node?.position = CGPoint(x: 0, y: -96)
                        other.node?.physicsBody?.isDynamic = false
                        //            other.node?.userData?.setObject(status.rescued, forKey: "status" as NSCopying)
                        contact.bodyB.node?.addChild(other.node!)
                        highScore.textComponent.moreScore(score: 500)
                        
                        let bonus = TextEntity(text: "500", Cords: positionToScore, name: "bonus")
                        bonus.textComponent.node.zPosition = Layer.mask.rawValue
                        addChild(bonus.textComponent.node)
                        let fadeOut = SKAction.fadeOut(withDuration: 0.5)
                        let fadeIn = SKAction.fadeIn(withDuration: 0.5)
                        let waiter = SKAction.wait(forDuration: 0.5)
                        let remover = SKAction.removeFromParent()
                        bonus.textComponent.node.run(SKAction.sequence([fadeIn, waiter, fadeOut, remover]))
                    }
                }
                return
            }
        }

        // drop spaceman if ground touches him while carried by starship

        if other.node?.name == "foreground" && contact.bodyB.node?.name == "starship"{
            if let node = hit.node as? SKSpriteNode {
                if node.parent != nil {
                    print("rule III")
                    let saving = contact.bodyB.node?.childNode(withName: "spaceman")
                    if saving != nil && saving?.userData?.object(forKey: "status") as? status == status.kidnapped {
                        //                saving?.position = (other.node?.position)!
                        saving?.position.x = self.playerNode.position.x - (other.node?.position.x)!
                        saving?.position.y = 96
                        saving?.removeFromParent()
                        other.node?.addChild(saving!)
                        saving?.userData?.setObject(status.rescued, forKey: "status" as NSCopying)
                        
                        //                let fX = other.node?.parent!.position.x
                        //                let positionToScore = CGPoint(x: saving!.position.x, y: saving!.position.y)
                        
                        let bonus = TextEntity(text: "250", Cords: (saving?.position)!, name: "bonus")
                        bonus.textComponent.node.zPosition = Layer.mask.rawValue
                        addChild(bonus.textComponent.node)
                        let fadeOut = SKAction.fadeOut(withDuration: 0.5)
                        let fadeIn = SKAction.fadeIn(withDuration: 0.5)
                        let waiter = SKAction.wait(forDuration: 0.5)
                        let remover = SKAction.removeFromParent()
                        bonus.textComponent.node.run(SKAction.sequence([fadeIn, waiter, fadeOut, remover]))
                        highScore.textComponent.moreScore(score: 250)
                    }
                }
            }
            return
        }

        // alien hit, releases spaceman

        if hit.node?.name == "alien" && contact.bodyA.node?.name == "missile" {
            if let node = hit.node as? SKSpriteNode {
                if node.parent != nil {
                    print("rule IV \(contact.bodyA.node?.name) \(contact.bodyB.node?.name)")
                    let victim = hit.node?.childNode(withName: "spaceman")
                    
                    //            let alienShadow = hit.node?.userData?.object(forKey:"shadow") as! SKSpriteNode
                    //            alienShadow.removeFromParent()
                    contact.bodyA.node?.removeFromParent()
                    
                    let parent2U = hit.node?.parent
                    //            hit.node?.removeFromParent()
                    if victim != nil {
                        victim?.position = (hit.node?.position)!
                        victim?.removeFromParent()
                        victim?.physicsBody?.isDynamic = true
                        parent2U?.addChild(victim!)
                    }
                    if let node = hit.node as? SKSpriteNode {
                        if node.parent != nil {
                            print("parent \(hit.node?.parent!.name)")
                            let fX = hit.node?.parent!.position.x
                            let positionToScore = CGPoint(x: (hit.node?.position.x)! + fX!, y: (hit.node?.position.y)!)
                            let shadow = hit.node?.userData?.object(forKey:"shadow") as! SKSpriteNode
                            (shadow as? SKSpriteNode)?.removeFromParent()
                            hit.node?.removeFromParent()
                            highScore.textComponent.moreScore(score: 100)
                            let bonus = TextEntity(text: "100", Cords: positionToScore, name: "bonus")
                            bonus.textComponent.node.zPosition = Layer.mask.rawValue
                            addChild(bonus.textComponent.node)
                            let fadeOut = SKAction.fadeOut(withDuration: 0.5)
                            let fadeIn = SKAction.fadeIn(withDuration: 0.5)
                            let waiter = SKAction.wait(forDuration: 0.5)
                            let remover = SKAction.removeFromParent()
                            
                            bonus.textComponent.node.run(SKAction.sequence([fadeIn, waiter, fadeOut, remover]))
                            doBodyCount()
                        }
                    }
                }
            }
            return
        }

        // player hits mine
        if other.node?.name == "mine" && contact.bodyA.node?.name == "starship" {
            if let node = other.node as? SKSpriteNode {
                if node.parent != nil {
                    print("rule XI")
                    
                    if lives != 0 {
                        let fadeOut = SKAction.fadeOut(withDuration: 2)
                        let fadeIn = SKAction.fadeIn(withDuration: 2)
                        let waiter = SKAction.wait(forDuration: 2)
                        contact.bodyA.node?.run(SKAction.sequence([fadeOut, waiter, fadeIn]))
                        
                        self.removeLives()
                        
                        lives -= 1
                    } else {
                        lives = 3
                        print("GameOver \(points)")
                        contact.bodyA.node?.removeFromParent()
                        other.node?.removeFromParent()
                        
                        let gameOver = SKLabelNode()
                        gameOver.text = "Game Over"
                        gameOver.position = CGPoint(x: self.view!.bounds.midX, y: self.view!.bounds.midY)
                        addChild(gameOver)
                        let restart = TouchableSprite(imageNamed: "OrangeBulletExplo1")
                        restart.name = "restart"
                        restart.position = CGPoint(x: self.view!.bounds.midX, y: self.view!.bounds.midY + 128)
                        restart.delegate = self
                        addChild(restart)
                    }
                }
            }
        }
        
        // player hits baiter
        
        if other.node?.name == "baiter" && contact.bodyA.node?.name == "starship" {
            
            if let node = other.node as? SKSpriteNode {
                if node.parent != nil {
                    print("rule X")
                    let shadow = other.node?.userData?.object(forKey:"shadow") as! SKSpriteNode
                    (shadow as? SKSpriteNode)?.removeFromParent()
                    other.node?.removeFromParent()
                    highScore.textComponent.moreScore(score: 100)
                    doBodyCount()
                }
            }
        }
        
        // player hots mutant
        
        if other.node?.name == "mutant" && contact.bodyA.node?.name == "starship" {
            
            if let node = other.node as? SKSpriteNode {
                if node.parent != nil {
                    print("rule IX")
                    let shadow = other.node?.userData?.object(forKey:"shadow") as! SKSpriteNode
                    (shadow as? SKSpriteNode)?.removeFromParent()
                    other.node?.removeFromParent()
                    highScore.textComponent.moreScore(score: 100)
                    doBodyCount()
                }
            }
        }
        
        // player hits bomber
        
        if other.node?.name == "bomber" && contact.bodyA.node?.name == "starship" {
            
            if let node = other.node as? SKSpriteNode {
                if node.parent != nil {
                    print("rule VIII")
                    let shadow = other.node?.userData?.object(forKey:"shadow") as! SKSpriteNode
                    (shadow as? SKSpriteNode)?.removeFromParent()
                    other.node?.removeFromParent()
                    highScore.textComponent.moreScore(score: 100)
                    doBodyCount()
                }
            }
        }
        
        // player hits lander
        
        if other.node?.name == "alien" && contact.bodyB.node?.name == "starship" {
            
            if let node = other.node as? SKSpriteNode {
                if node.parent != nil {
                    print("rule XIII")
                    let shadow = other.node?.userData?.object(forKey:"shadow") as! SKSpriteNode
                    (shadow as? SKSpriteNode)?.removeFromParent()
                    other.node?.removeFromParent()
                    highScore.textComponent.moreScore(score: 100)
                    doBodyCount()
                }
            }
        }
        
        // fire hits mine, disappears- but no extra points
        
        if hit.node?.name == "mine" {
            if let node = hit.node as? SKSpriteNode {
                if node.parent != nil {
                    node.removeFromParent()
                }
            }
        }

        // fire hits bomber or mine or mutant or baiter
        if hit.node?.name == "bomber"  || hit.node?.name == "mutant" || hit.node?.name == "baiter"  {
            if let node = hit.node as? SKSpriteNode {
                if node.parent != nil {
                    print("rule VII")
                    let fX = hit.node?.parent!.position.x
                    let positionToScore = CGPoint(x: (hit.node?.position.x)! + fX!, y: (hit.node?.position.y)!)
                    deleteEntry(entry2D: node)
                    let shadow = node.userData?.object(forKey:"shadow") as! SKSpriteNode
                    (shadow as? SKSpriteNode)?.removeFromParent()
                    node.removeFromParent()
                    highScore.textComponent.moreScore(score: 100)
                    let bonus = TextEntity(text: "100", Cords: positionToScore, name: "bonus")
                    bonus.textComponent.node.zPosition = Layer.mask.rawValue
                    addChild(bonus.textComponent.node)
                    let fadeOut = SKAction.fadeOut(withDuration: 0.5)
                    let fadeIn = SKAction.fadeIn(withDuration: 0.5)
                    let waiter = SKAction.wait(forDuration: 0.5)
                    let remover = SKAction.removeFromParent()
                    bonus.textComponent.node.run(SKAction.sequence([fadeIn, waiter, fadeOut, remover]))
                    doBodyCount()
                }
            }
        }
        


        // spaceman falling to ground
        if other.node?.name == "foreground" {
            if let node = other.node as? SKSpriteNode {
                if node.parent != nil {
                    print("rule V")
                    contact.bodyB.node?.physicsBody?.isDynamic = false
                    let poc = CGPoint(x: (contact.bodyB.node?.position.x)!, y: 96)
                    contact.bodyB.node?.run(SKAction.move(to: poc, duration: 0.5))
                    highScore.textComponent.moreScore(score: 250)
                }
            }
            return
        }

        // shoot the spaceman and he will disppear

        if hit.node?.name == "spaceman" && contact.bodyB.node?.name != "starship" {
            if let node = hit.node as? SKSpriteNode {
                if node.parent != nil {
                    print("rule VI")
                    hit.node?.removeFromParent()
                    highScore.textComponent.lessScore(score: 100)
                }
            }
        }
    }
    
    var previousDirection:String?
    
    func restart() {
        let scene = GameScene(size: CGSize(width: self.view!.bounds.width * 2, height: self.view!.bounds.height * 2))
        let skView = self.view as? SKView
        skView!.showsFPS = true
        skView!.showsNodeCount = true
        skView!.showsPhysics = true
        skView!.ignoresSiblingOrder = true
        scene.scaleMode = .aspectFit
        skView!.presentScene(scene)
    }
    
    
    func deleteEntry(entry2D: SKSpriteNode) {
        switch entry2D.name {
        case "bomber":
            let classOf = entry2D.userData?.object(forKey: "class") as? BomberEntity
            if let i = bombers.index(where: { $0 == classOf }) {
                bombers.remove(at: i)
                print("deleted Bomber")
            }
            break
        case "mutant":
            let classOf = entry2D.userData?.object(forKey: "class") as? MutantEntity
            if let i = mutants.index(where: { $0 == classOf }) {
                mutants.remove(at: i)
                print("deleted Mutant")
            }
            break
        case "baiter":
            let classOf = entry2D.userData?.object(forKey: "class") as? BaitEntity
            if let i = baiters.index(where: { $0 == classOf }) {
                baiters.remove(at: i)
                print("deleted Baiter")
            }
            break
        case "alien":
            let classOf = entry2D.userData?.object(forKey: "class") as? LanderEntity
            if let i = landers.index(where: { $0 == classOf }) {
                landers.remove(at: i)
                print("deleted Baiter")
            }
            break
        default:
            break
        }
        
    }
    
    
    func spriteTouched(box: TouchableSprite) {
        switch box.name {
        case "restart":
            restart()
            
        case "bomber":
            print("bomber.position \(box.position)")
        case "starship":
            //fuck
            self.enumerateChildNodes(withName: "mine") { (node, stop) in
                print("node.name")
            }
        case "spaceman":
            print("player \(box.position)")
        case "baiter":
            print("baiter \(box.position) ")
        case "up":
            player.movementComponent.applyImpulseUp(lastUpdateTimeInterval)
        case "down":
            player.movementComponent.applyImpulseDown(lastUpdateTimeInterval)
            //fuck
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
                player.movementComponent.setScreen(entity: scene!)
                player.movementComponent.applyImpulseLeft(lastUpdateTimeInterval)
                radar.position = CGPoint(x: self.view!.bounds.maxX / 2, y: self.view!.bounds.maxY * 2 - self.view!.bounds.maxY * 0.4)
//                shadow.movementComponent.leftTexture()
            case "right":
                advancedArrow.hudComponent.changeTexture(imageNamed: "LeftArrow")
                moveRight = true
                moveLeft = false
                player.movementComponent.setScreen(entity: scene!)
                player.movementComponent.applyImpulseRight(lastUpdateTimeInterval)
                radar.position = CGPoint(x: self.view!.bounds.maxX, y: self.view!.bounds.maxY * 2 - self.view!.bounds.maxY * 0.4)
//                shadow.movementComponent.rightTexture()
            default:
                break
            }
        case "fire":
            let mshape = CGRect(x: 0, y: 0, width: 32, height: 6)
            let missileX = FireEntity(rect: mshape, xCord: 0, yCord: 0)
            
            playerNode.run(SKAction.playSoundFileNamed("science_fiction_laser_007.mp3", waitForCompletion: false))
            
            
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
            moveLeft = false
            moveRight = false
            groundSpeed = 150
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
