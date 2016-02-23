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
    private var pauseButton: SKButton!
    private let ButtonsScale: CGFloat = 0.8
    private var pointsLabel: PointsCounterNode!
    
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
    private var xAcceleration = 0.0
    private var yAcceleration = 0.0
    
    private var wormAcceleration = CGVector(dx: 0, dy: 0)
    private var wormVelocity = CGVector(dx: 0, dy: 0)
    
    private let MaxWormAcceleration: CGFloat = 400.0
    private let MaxWormSpeed: CGFloat = 200.0
    private var lastUpdateTime: CFTimeInterval = 0
    
    
    // MARK: - Presenting a Scene
    override func didMoveToView(view: SKView) {
        physicsWorld.contactDelegate = self
        
        self.background()
        self.setPlayButton()
        self.setPauseButton()
        pointsLabel = PointsCounterNode(imageNamed: "Points", frameSize: self.frame.size, delegate: self)
        pointsLabel.position = CGPointMake(self.frame.maxX * 15/16 - pointsLabel.size.width / 2, self.frame.maxY * 15/16)
        self.addChild(pointsLabel)
        
        // Physics Bodies
        self.createWorm()
        self.createPoint()
        self.createWalls()
        
        // Accelerometer
        self.startMonitoringAcceleratrion()
    }
    
    // MARK: - Deinitializer
    deinit {
        self.stopMoitoringAcceleration()
    }
    
    // MARK: - Handling Core Motion
    func startMonitoringAcceleratrion() {
        if motionManager.accelerometerAvailable {
            motionManager.startAccelerometerUpdates()
            print("Accelerometer updates on")
        }
    }
    
    func stopMoitoringAcceleration() {
        if motionManager.accelerometerAvailable && motionManager.accelerometerActive {
            motionManager.stopAccelerometerUpdates()
            print("Accelerometer updates off")
        }
    }
    
    // MARK: - Update Worm
    func updateWormAcceleration() {
        if let acceleration = motionManager.accelerometerData?.acceleration {
            let factor = 0.75
            self.xAcceleration = acceleration.x * factor + self.xAcceleration * (1 - factor)
            self.yAcceleration = acceleration.y * factor + self.yAcceleration * (1 - factor)
            
            wormAcceleration.dx = CGFloat(self.yAcceleration) * -MaxWormAcceleration
            wormAcceleration.dy = CGFloat(self.xAcceleration) * MaxWormAcceleration
        }
    }
    
    func updateWorm(dt: CFTimeInterval) {
        wormVelocity.dx = wormVelocity.dx + wormAcceleration.dx * CGFloat(dt)
        wormVelocity.dy = wormVelocity.dy + wormAcceleration.dy * CGFloat(dt)

        wormVelocity.dx = max( -MaxWormSpeed, min(MaxWormSpeed, wormVelocity.dx))
        wormVelocity.dy = max( -MaxWormSpeed, min(MaxWormSpeed, wormVelocity.dy))

        var newX = worm.position.x + wormVelocity.dx * CGFloat(dt)
        var newY = worm.position.y + wormVelocity.dy * CGFloat(dt)
        
        newX = min(size.width, max(0, newX))
        newY = min(size.height, max(0, newY))
    }
    
    // MARK: - Responding to Touch Events
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    }
    
    // MARK: - Executing the Animation Loop
    override func update(currentTime: CFTimeInterval) {
        pointsLabel.pointLabel.text = "\(pointsLabel.points)"
        
        let deltaTime = max(1.0/30, currentTime - lastUpdateTime)
        lastUpdateTime = currentTime
        
        updateWormAcceleration()
        updateWorm(deltaTime)
    }

    override func didSimulatePhysics() {
        worm.physicsBody?.velocity = CGVector(dx: xAcceleration * 400, dy: yAcceleration * 400)
    }
    
    // MARK: - Responding to Contact Events
    func didBeginContact(contact: SKPhysicsContact) {
        var bodyA: SKPhysicsBody
        var bodyB: SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            bodyA = contact.bodyA
            bodyB = contact.bodyB
        } else {
            bodyA = contact.bodyB
            bodyB = contact.bodyA
        }
        
        if bodyA.categoryBitMask == CollisionCategoryBitmask.Point || bodyB.categoryBitMask == CollisionCategoryBitmask.Point {
            star.removeFromParent()
            self.createPoint()
            pointsLabel.points += 1
        }

        if bodyA.categoryBitMask == CollisionCategoryBitmask.Wall || bodyB.categoryBitMask == CollisionCategoryBitmask.Wall {
            self.setEndGame()
        }
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
        playButton = SKButton(defaultButtonImage: "PlayBigButton", activeButtonImage: "PlayBigButtonShadow", buttonAction: removePlayButton)
        playButton.setScale(self.ButtonsScale)
        playButton.zPosition = ObjectsZPositions.hud
        playButton.position = CGPointMake(self.frame.midX, self.frame.midY)
        self.addChild(playButton)
    }
    
    func setPauseButton() {
        pauseButton = SKButton(defaultButtonImage: "PauseButton", activeButtonImage: "PauseButtonShadow", buttonAction: pauseGame)
        pauseButton.zPosition = ObjectsZPositions.hud
        pauseButton.position = CGPointMake(self.frame.maxX * 1/10, self.frame.maxY * 15/16)
        self.addChild(pauseButton)
    }
    
    func setEndGame() {
        pauseButton.enabled = false
        worm.physicsBody?.dynamic = false
        let endGame = EndGameNode(imageNamed: "Warning", delegate: self)
        endGame.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        self.addChild(endGame)
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
        star = Point(imageNamed: "Star", delegate: self)
        star.position = CGPointMake(CGFloat(arc4random() % UInt32(self.frame.maxX - self.frame.maxX * 1/8)),
                                    CGFloat(arc4random() % UInt32(self.frame.maxY - self.pointsLabel.size.height - self.frame.height * 1/16)))
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
        if playButton != nil {
            playButton.removeFromParent()
        }
        self.wormVector = worm.physicsBody?.velocity
        worm.physicsBody?.dynamic = false
        self.addChild(PauseMenu(imageNamed: "PauseMenu", frameSize: self.frame.size, delegate: self))
    }
}
