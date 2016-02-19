//
//  GameScene.swift
//  Worm
//
//  Created by Piotr Pawluś on 18/02/16.
//  Copyright © 2016 Piotr Pawluś. All rights reserved.
//

import SpriteKit
import CoreMotion

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // MARK: - Properties
    private var playButton: SKButton!
    private let buttonsScale: CGFloat = 0.8
    private var pointsLabel: PointsNode!
    
    // Physics Bodies
    var worm: SKSpriteNode!
    private var star: SKSpriteNode! // thing to collect
    var wormDynamic: Bool {
        get {
            return (worm.physicsBody?.dynamic)!
        }
        set {
            if worm != nil {
                worm.physicsBody?.dynamic = newValue
            }
        }
    }
    private var wormVector: CGVector!
    var vector: CGVector {
        get {
            if worm != nil {
                return self.wormVector
            } else {
                return CGVector(dx: 0.0, dy: 0.0)
            }
        }
    }
    
    // Accelemeter
    private let motionManager = CMMotionManager()
    private var xAcceleration: CGFloat = 0.0
    private var yAcceleration: CGFloat = 0.0
    
    // MARK: - Presenting a Scene
    override func didMoveToView(view: SKView) {
        physicsWorld.contactDelegate = self
        
        self.background()
        self.setPlayButton()
        self.setPauseButton()
        pointsLabel = PointsNode(imageNamed: "Points", frameSize: self.frame.size, delegate: self)
        pointsLabel.position = CGPointMake(self.frame.maxX * 15/16 - pointsLabel.size.width / 2, self.frame.maxY * 15/16)
        self.addChild(pointsLabel)
        
        // Physics Bodies
        self.createWorm()
        self.createPoint()
        self.createWalls()
        
        // Accelerometer
        motionManager.accelerometerUpdateInterval = 0.1
        motionManager.startAccelerometerUpdatesToQueue(NSOperationQueue.currentQueue()!) {
            (accelerometerData: CMAccelerometerData?, error: NSError?) -> Void in
            let acceleration = accelerometerData!.acceleration
            self.xAcceleration = CGFloat(acceleration.x) + (self.xAcceleration * 0.25)
            self.yAcceleration = CGFloat(acceleration.y) + (self.yAcceleration * 0.25)
        }
    }
    
    // MARK: - Responding to Touch Events
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    }
    
    // MARK: - Executing the Animation Loop
    override func update(currentTime: CFTimeInterval) {
        pointsLabel.pointLabel.text = "1"
    }

    override func didSimulatePhysics() {
        worm.physicsBody?.velocity = CGVector(dx: xAcceleration * 400, dy: yAcceleration * 400)
    }
    
    // MARK: - Responding to Contact Events
    func didBeginContact(contact: SKPhysicsContact) {
        print("CONTACT!")
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
        worm.physicsBody?.collisionBitMask = CollisionCategoryBitmask.Nil
        worm.physicsBody?.contactTestBitMask = CollisionCategoryBitmask.Wall | CollisionCategoryBitmask.Point
        self.addChild(worm)
    }
    
    func createPoint() {
        star = SKSpriteNode(imageNamed: "Star")
        star.position = CGPointMake(CGFloat(arc4random() % UInt32(self.frame.maxX - self.frame.maxX * 1/8)),
                                    CGFloat(arc4random() % UInt32(self.frame.maxY - self.pointsLabel.size.height - self.frame.height * 1/16)))
        star.setScale(0.5)

        star.zPosition = ObjectsZPositions.middleground
        star.physicsBody = SKPhysicsBody(rectangleOfSize: star.size)
        star.physicsBody?.dynamic = false
        star.physicsBody?.categoryBitMask = CollisionCategoryBitmask.Point
        star.physicsBody?.contactTestBitMask = CollisionCategoryBitmask.Nil
        star.physicsBody?.collisionBitMask = CollisionCategoryBitmask.Worm
        self.addChild(star)
    }
    
    func createWalls() {
        let down = SKNode()
        down.physicsBody = SKPhysicsBody(edgeFromPoint: CGPoint(x: CGRectGetMinX(self.frame), y: CGRectGetMinY(self.frame)),
                                               toPoint: CGPoint(x: CGRectGetMaxX(self.frame), y: CGRectGetMinY(self.frame)))
        down.physicsBody?.categoryBitMask = CollisionCategoryBitmask.Wall
        down.physicsBody?.contactTestBitMask = CollisionCategoryBitmask.Worm
        down.physicsBody?.collisionBitMask = CollisionCategoryBitmask.Worm
        down.zPosition = ObjectsZPositions.middleground
        self.addChild(down)
        
        let up = SKNode()
        up.physicsBody = SKPhysicsBody(edgeFromPoint: CGPoint(x: CGRectGetMinX(self.frame), y: CGRectGetMaxY(self.frame)),
                                             toPoint: CGPoint(x: CGRectGetMaxX(self.frame), y: CGRectGetMaxY(self.frame)))
        up.physicsBody?.categoryBitMask = CollisionCategoryBitmask.Wall
        up.physicsBody?.contactTestBitMask = CollisionCategoryBitmask.Worm
        up.physicsBody?.collisionBitMask = CollisionCategoryBitmask.Worm
        up.zPosition = ObjectsZPositions.middleground
        self.addChild(up)
        
        let left = SKNode()
        left.physicsBody = SKPhysicsBody(edgeFromPoint: CGPoint(x: CGRectGetMinX(self.frame), y: CGRectGetMinY(self.frame)),
                                               toPoint: CGPoint(x: CGRectGetMinX(self.frame), y: CGRectGetMaxY(self.frame)))
        
        left.physicsBody?.categoryBitMask = CollisionCategoryBitmask.Wall
        left.physicsBody?.contactTestBitMask = CollisionCategoryBitmask.Worm
        left.physicsBody?.collisionBitMask = CollisionCategoryBitmask.Worm
        left.zPosition = ObjectsZPositions.middleground
        self.addChild(left)
        
        let right = SKNode()
        right.physicsBody = SKPhysicsBody(edgeFromPoint: CGPoint(x: CGRectGetMaxX(self.frame), y: CGRectGetMinY(self.frame)),
                                                toPoint: CGPoint(x: CGRectGetMaxX(self.frame), y: CGRectGetMaxY(self.frame)))
        
        right.physicsBody?.categoryBitMask = CollisionCategoryBitmask.Wall
        right.physicsBody?.contactTestBitMask = CollisionCategoryBitmask.Worm
        right.physicsBody?.collisionBitMask = CollisionCategoryBitmask.Worm
        right.zPosition = ObjectsZPositions.middleground
        self.addChild(right)
    }
    
    // MARK: - Buttons actions
    func removePlayButton() {
        playButton.removeFromParent()
        worm.physicsBody?.dynamic = true
    }
    
    func pauseGame() {
        self.wormVector = worm.physicsBody?.velocity
        worm.physicsBody?.dynamic = false
        self.addChild(PauseMenu(imageNamed: "PauseMenu", frameSize: self.frame.size, delegate: self))
    }
}
