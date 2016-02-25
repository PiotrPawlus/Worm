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
        self.setScale(0.5)
        
        self.zPosition = ObjectsZPositions.middleground
        self.physicsBody = SKPhysicsBody(rectangleOfSize: self.size)
        self.physicsBody?.dynamic = false
        self.physicsBody?.categoryBitMask = CollisionCategoryBitmask.Point
        self.physicsBody?.contactTestBitMask = CollisionCategoryBitmask.Nil
        self.physicsBody?.collisionBitMask = CollisionCategoryBitmask.Worm

    }
}
