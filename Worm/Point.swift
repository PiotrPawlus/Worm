//
//  Point.swift
//  Worm
//
//  Created by Piotr Pawluś on 19/02/16.
//  Copyright © 2016 Piotr Pawluś. All rights reserved.
//

import SpriteKit

class Point: SKSpriteNode {
    private weak var delegate: SKScene!
    private let scale: CGFloat = 0.5
    // MARK: - initializers
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(imageNamed: String, delegate: SKScene) {
        
        self.delegate = delegate
        
        
        let texture = SKTexture(imageNamed: imageNamed)
        self.delegate = delegate
        let pointSzie = texture.size()
        super.init(texture: texture, color: UIColor.clearColor(), size: pointSzie)
        self.setScale(scale)
        
        self.zPosition = ObjectsZPositions.middleground
        self.physicsBody = SKPhysicsBody(circleOfRadius: self.size.width * scale, center: CGPoint(x: 0.0, y: -self.frame.maxY * 1/4))
        self.physicsBody?.dynamic = false
        self.physicsBody?.categoryBitMask = CollisionCategoryBitmask.Point
        self.physicsBody?.contactTestBitMask = CollisionCategoryBitmask.Nil
        self.physicsBody?.collisionBitMask = CollisionCategoryBitmask.Worm

    }
}
