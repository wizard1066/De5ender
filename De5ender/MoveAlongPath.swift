//
//  File.swift
//  SKDefender
//
//  Created by localadmin on 07.11.18.
//  Copyright © 2018 ch.cqd.skdefender. All rights reserved.
//

import SpriteKit

class demo: NSObject {
    
    var logo: SKSpriteNode!
    
    func mover() {

        logo = SKSpriteNode(imageNamed:"SwiftLogo")

//        logo.position = CGPoint(x: self.view!.bounds.minX, y: self.view!.bounds.minY)
//        self.addChild(logo)

        var path = CGMutablePath()
        path.move(to: CGPoint(x: 0, y: 0))
        path.move(to: CGPoint(x: 50, y: 100))

        var followLine = SKAction.follow(path, asOffset: true, orientToPath: false, duration: 3.0)

        var reversedLine = followLine.reversed()

        var square = UIBezierPath(rect: CGRect(x: 0, y: 0, width: 100, height: 100))
        var followSquare = SKAction.follow(square.cgPath, asOffset: true, orientToPath: false, duration: 5.0)

        var circle = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: 100, height: 100), cornerRadius: 100)
        var followCircle = SKAction.follow(circle.cgPath, asOffset: true, orientToPath: false, duration: 5.0)


        logo.run(SKAction.sequence([followLine,reversedLine,followSquare,followCircle]))
            }
}
