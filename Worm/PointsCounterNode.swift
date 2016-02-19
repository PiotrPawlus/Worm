//
//  PointsNode.swift
//  Worm
//
//  Created by Piotr Pawluś on 18/02/16.
//  Copyright © 2016 Piotr Pawluś. All rights reserved.
//

import SpriteKit

class PointsCounterNode: SKSpriteNode {
    
    private var delegate: SKScene!
    private var pointsNodeSize: CGSize!
    var pointLabel: SKLabelNode!
    var points = 0
    
    // MARK: - initializers
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(imageNamed: String, frameSize: CGSize, delegate: SKScene) {
        let texture = SKTexture(imageNamed: imageNamed)
        
        self.delegate = delegate
        pointsNodeSize = CGSize(width: texture.size().width, height: texture.size().height)
        super.init(texture: texture, color: UIColor.clearColor(), size: pointsNodeSize)
        self.position = CGPointMake(frameSize.width / 2, frameSize.height / 2)
        self.zPosition = ObjectsZPositions.hud
    
        self.setPointLabel()
    }
    
    // MARK: - Points node objects
    func setPointLabel() {
        pointLabel = SKLabelNode(fontNamed: "ChalkboardSE-Bold")
        pointLabel.fontSize = 22
        pointLabel.fontColor = SKColor.whiteColor()
        pointLabel.position = CGPoint(x: pointsNodeSize.width * 1/5, y: -pointsNodeSize.height * 1/4)
        pointLabel.text = "\(points)"
        self.addChild(pointLabel)
    }
    
}
