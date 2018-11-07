//
//  TouchableSprite.swift
//  SKBird
//
//  Created by localadmin on 06.11.18.
//  Copyright © 2018 ch.cqd.skbird. All rights reserved.
//

import SpriteKit

protocol touchMe: NSObjectProtocol {
    func spriteTouched(box: TouchableSprite)
}

class TouchableSprite: SKSpriteNode {
    weak var delegate: touchMe!
    
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
        self.isUserInteractionEnabled = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:)has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        delegate.spriteTouched(box: self)
    }
}
