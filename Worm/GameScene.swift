//
//  GameScene.swift
//  Worm
//
//  Created by Piotr Pawluś on 18/02/16.
//  Copyright © 2016 Piotr Pawluś. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    private var playButton: SKButton!
    private let buttonsScale: CGFloat = 0.8
    private var pointsLabel: PointsNode!
    
    // Physics Bodies
    var worm: SKSpriteNode!
    var walls: [SKNode]!
    var star: SKSpriteNode! // thing to collect

    // MARK: - Presenting a Scene
    override func didMoveToView(view: SKView) {
        
        self.background()
        self.setPlayButton()
        self.setPauseButton()
        pointsLabel = PointsNode(imageNamed: "Points", frameSize: self.frame.size, delegate: self)
        pointsLabel.position = CGPointMake(self.frame.maxX * 15/16 - pointsLabel.size.width / 2, self.frame.maxY * 15/16)
        self.addChild(pointsLabel)
        
        // Physics Bodies
        self.createWorm()
        self.createPoint()
    }
    
    
    // MARK: - Responding to Touch Events
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    }
    
    // MARK: - Executing the Animation Loop
    override func update(currentTime: CFTimeInterval) {
        pointsLabel.pointLabel.text = "1"
    }
    
    // MARK: - GameScene Sprite Nodes
    func background() {
        let backgorundSprite = SKSpriteNode(imageNamed: "background2")
        backgorundSprite.zPosition = ObjectsZPositions.background
        backgorundSprite.size = self.frame.size
        backgorundSprite.position = CGPointMake(self.frame.midX, self.frame.midY)
        self.addChild(backgorundSprite)
    }
    
    func setPlayButton() {
        playButton = SKButton(defaultButtonImage: "PlayBigButton", activeButtonImage: "PlayBigButton", buttonAction: removePlayButton)
        playButton.setScale(self.buttonsScale)
        playButton.zPosition = ObjectsZPositions.hud
        playButton.position = CGPointMake(self.frame.midX, self.frame.midY)
        self.addChild(playButton)
    }
    
    func setPauseButton() {
        let pauseButton = SKButton(defaultButtonImage: "PauseButton", activeButtonImage: "PauseButtonShadow", buttonAction: pauseGame)
        pauseButton.zPosition = ObjectsZPositions.hud
        pauseButton.position = CGPointMake(self.frame.maxX * 1/10, self.frame.maxY * 15/16)
        self.addChild(pauseButton)
    }
    
    // MARK: - GameScene Physic Bodies
    func createWorm() {
        worm = SKSpriteNode(imageNamed: "Worm")
        worm.position = CGPointMake(self.frame.midX, self.frame.midY)
        worm.zPosition = ObjectsZPositions.middleground
        worm.setScale(0.5) // to delete, replace with new worm sprite
        
        worm.physicsBody = SKPhysicsBody(rectangleOfSize: worm.size)
        worm.physicsBody?.dynamic = false // at start
        worm.physicsBody?.allowsRotation = true
        worm.physicsBody?.affectedByGravity = false
        
        worm.physicsBody?.usesPreciseCollisionDetection = true
        worm.physicsBody?.categoryBitMask = CollisionCategoryBitmask.Worm
        worm.physicsBody?.collisionBitMask = 0x00
        worm.physicsBody?.contactTestBitMask = CollisionCategoryBitmask.Wall | CollisionCategoryBitmask.Point
        self.addChild(worm)
    }
    
    func createPoint() {
        star = SKSpriteNode(imageNamed: "Star")
        star.position = CGPointMake(CGFloat(arc4random() % UInt32(self.frame.maxX - self.frame.maxX * 1/8)),
                                    CGFloat(arc4random() % UInt32(self.frame.maxY - self.pointsLabel.size.height - self.frame.height * 1/16)))
        star.setScale(0.5)

        star.physicsBody = SKPhysicsBody(rectangleOfSize: star.size)
        star.physicsBody?.dynamic = false
        star.physicsBody?.categoryBitMask = CollisionCategoryBitmask.Point
        star.physicsBody?.contactTestBitMask = 0x00
        star.physicsBody?.collisionBitMask = CollisionCategoryBitmask.Worm
        self.addChild(star)
    }
    
    // MARK: - Buttons actions
    func removePlayButton() {
        playButton.removeFromParent()
        worm.physicsBody?.affectedByGravity = true // to delete
        worm.physicsBody?.dynamic = true
    }
    
    func pauseGame() {
        print("GAME WILL BE PAUSED HERE")
        self.addChild(PauseMenu(imageNamed: "PauseMenu", frameSize: self.frame.size, delegate: self))
    }
}
