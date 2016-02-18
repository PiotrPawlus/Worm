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

    // MARK: - Presenting a Scene
    override func didMoveToView(view: SKView) {
        
        self.background()
        self.setPlayButton()

    }
    
    
    // MARK: - Responding to Touch Events
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    }
    
    // MARK: - Executing the Animation Loop
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
    
    // MARK: - MenuScene objects
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
    
    func removePlayButton() {
        playButton.removeFromParent()
    }
}
