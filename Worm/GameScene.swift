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
    private var hudBar: SKSpriteNode!
    
    // Physics Bodies
    private var worm: SKSpriteNode!
    private var star: SKSpriteNode! // thing to collect
    var unpauseWorm: Bool {
        get {
            if worm.physicsBody != nil {
                return (worm.physicsBody?.dynamic)! && (worm.physicsBody?.allowsRotation)!
            } else {
                return false
            }
        }
        set {
            self.startMonitoringAcceleratrion()
            if worm != nil {
                worm.physicsBody?.dynamic = newValue
                worm.physicsBody?.allowsRotation = newValue
            }
        }
    }
        
    // Accelemeter
    private let motionManager = CMMotionManager()
    private var xAcceleration = 0.0
    private var yAcceleration = 0.0
    
    private var wormAcceleration = CGVector(dx: 0, dy: 0)
    private var wormVelocity = CGVector(dx: 0, dy: 0)
    
    private let MaxWormAcceleration: CGFloat = 150.0
    private var maxWormSpeed: CGFloat = 20.0
    private var lastUpdateTime: CFTimeInterval = 0

    // Math
    let Pi = CGFloat(M_PI)
    let DegreesToRadians = CGFloat(M_PI) / 180
    let RadiansToDegrees = 180 / CGFloat(M_PI)
    
    
    // MARK: - Initialiser
    override init(size: CGSize) {
        super.init(size: size)
        
        PauseMenu.gamePaused = false        
        EndGameNode.endGame = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Presenting a Scene
    override func didMoveToView(view: SKView) {
        
        physicsWorld.contactDelegate = self
        self.background()
        self.setPlayButton()
        self.setHud()
        self.setPauseButton()
        pointsLabel = PointsCounterNode(imageNamed: "PointsApple", frameSize: self.frame.size, delegate: self)
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
        }
    }
    
    func stopMoitoringAcceleration() {
        if motionManager.accelerometerAvailable && motionManager.accelerometerActive {
            motionManager.stopAccelerometerUpdates()
        }
    }
    
    // MARK: - Update Worm Sprite
    func updateWormAcceleration() {
        let factor = 0.75
        
        guard let acceleration = motionManager.accelerometerData?.acceleration else {
            return
        }
        
        self.xAcceleration = acceleration.x * factor + self.xAcceleration * (1 - factor)
        self.yAcceleration = acceleration.y * factor + self.yAcceleration * (1 - factor)
        
        wormAcceleration.dx = CGFloat(self.xAcceleration) * MaxWormAcceleration
        wormAcceleration.dy = CGFloat(self.yAcceleration) * MaxWormAcceleration
    }
    
    func updateWorm(dt: CFTimeInterval) {
        wormVelocity.dx = wormVelocity.dx + wormAcceleration.dx * CGFloat(dt)
        wormVelocity.dy = wormVelocity.dy + wormAcceleration.dy * CGFloat(dt)

        wormVelocity.dx = max( -maxWormSpeed, min(maxWormSpeed, wormVelocity.dx))
        wormVelocity.dy = max( -maxWormSpeed, min(maxWormSpeed, wormVelocity.dy))

        var newX = worm.position.x + wormVelocity.dx * CGFloat(dt)
        var newY = worm.position.y + wormVelocity.dy * CGFloat(dt)
        
        newX = min(size.width, max(0, newX))
        newY = min(size.height, max(0, newY))
        
        worm.position = CGPoint(x: newX, y: newY)

        
        let angle = atan2(wormVelocity.dy, wormVelocity.dx)
        worm.zRotation = angle + 90.0 * DegreesToRadians
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
        if (worm.physicsBody?.allowsRotation)! && (worm.physicsBody?.dynamic)! {
            updateWorm(deltaTime)
        }
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
            self.maxWormSpeed += 2.5
        }

        if bodyA.categoryBitMask == CollisionCategoryBitmask.Wall || bodyB.categoryBitMask == CollisionCategoryBitmask.Wall {
            if !PauseMenu.gamePaused {
                self.setEndGame()
            }
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
    
    func setHud() {
        hudBar = SKSpriteNode(imageNamed: "bar")
        hudBar.zPosition = ObjectsZPositions.hud
        hudBar.position = CGPointMake(self.frame.midX, self.frame.maxY * 15/16)
        
        let hudSize = CGSize(width: hudBar.size.width, height: hudBar.size.height * 7/8)
        hudBar.physicsBody = SKPhysicsBody(rectangleOfSize: hudSize)
        hudBar.physicsBody?.categoryBitMask = CollisionCategoryBitmask.Wall
        hudBar.physicsBody?.contactTestBitMask = CollisionCategoryBitmask.Worm
        hudBar.physicsBody?.collisionBitMask = CollisionCategoryBitmask.Worm
        hudBar.physicsBody?.affectedByGravity = false
        hudBar.physicsBody?.dynamic = false
        self.addChild(hudBar)
    }
    
    func setPauseButton() {
        pauseButton = SKButton(defaultButtonImage: "PauseButton", activeButtonImage: "PauseButtonShadow", buttonAction: pauseGame)
        pauseButton.zPosition = ObjectsZPositions.hudObjects
        pauseButton.position = CGPointMake(self.frame.maxX * 1/10, self.frame.maxY * 15/16)
        self.addChild(pauseButton)
    }
    
    func setEndGame() {
        if !PauseMenu.gamePaused {
            pauseButton.enabled = false
            EndGameNode.endGame = true
            worm.physicsBody?.dynamic = false
            worm.physicsBody?.allowsRotation = false
            self.stopMoitoringAcceleration()
            let endGame = EndGameNode(imageNamed: "EndGame", delegate: self)
            endGame.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
            self.addChild(endGame)
        }
    }
    
    // MARK: - GameScene Physic Bodies
    func createWorm() {
        worm = SKSpriteNode(imageNamed: "robak")
        worm.position = CGPointMake(self.frame.midX, self.frame.midY)
        worm.zPosition = ObjectsZPositions.middleground
        worm.setScale(0.5) 
        
        let heightScale: CGFloat = 0.95
        let widthScale: CGFloat = 0.8
        let wormSize = CGSize(width: worm.size.width * widthScale, height: worm.size.height * heightScale)
        worm.physicsBody = SKPhysicsBody(rectangleOfSize: wormSize)
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
        star = Point(imageNamed: "apple", delegate: self)
        
        let maxY = self.frame.maxY - self.hudBar.size.height
        star.position = CGPointMake( CGFloat(arc4random() % UInt32(self.frame.maxX * 7/9)) + self.frame.maxX * 1/9 ,
                                     CGFloat(arc4random() % UInt32(maxY * 7/9)) + maxY * 1/9)
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
        if !EndGameNode.endGame {
            self.wormVelocity = (worm.physicsBody?.velocity)!
            worm.physicsBody?.dynamic = false
            worm.physicsBody?.allowsRotation = false
//            PauseMenu.gamePaused = true
            if playButton != nil {
                playButton.removeFromParent()
            }
            self.stopMoitoringAcceleration()
            self.addChild(PauseMenu(imageNamed: "PauseMenu", frameSize: self.frame.size, delegate: self))
        }
    }
}
