//
//  MenuScene.swift
//  Worm
//
//  Created by Piotr Pawluś on 18/02/16.
//  Copyright © 2016 Piotr Pawluś. All rights reserved.
//

import SpriteKit

class MenuScene: SKScene {

    private let aspectRatio: CGFloat = 0.8
    // MARK: - Presenting a Scene
    override func didMoveToView(view: SKView) {

        self.background()
        self.singlePlayerBtn()
        self.multiPlayerBtn()
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
    
    func singlePlayerBtn() {
        let singlePlayerBtn = SKButton(defaultButtonImage: "SinglePlayerEnabled", activeButtonImage: "SinglePlayerButtonShadow", buttonAction: goToSinglePlayerScene)
        singlePlayerBtn.zPosition = ObjectsZPositions.hud
        singlePlayerBtn.setScale(self.aspectRatio)
        singlePlayerBtn.position = CGPointMake(self.frame.midX, self.frame.maxY * 5/9)
        self.addChild(singlePlayerBtn)
    }
    
    func multiPlayerBtn() {
        let multiPlayerBtn = SKButton(defaultButtonImage: "MultiPlayer", activeButtonImage: "MultiPlayerButtonShadow", disabledButtonImage: "MultiPlayerLocked", buttonAction: goToMultiPlayerScene)
        multiPlayerBtn.zPosition = ObjectsZPositions.hud
        multiPlayerBtn.setScale(self=.aspectRatio)
        multiPlayerBtn.position = CGPointMake(self.frame.midX, self.frame.maxY * 4/9)
        self.addChild(multiPlayerBtn)
    }
    
    // MARK: - Present a Scene
    func goToSinglePlayerScene() {
        print("SINGLE PLAYER SCENE WILL PRESENT HERE")
    }
    
    func goToMultiPlayerScene() {
        print("MULTIPLAYER SCENE WILL PRESETN HERE")
    }
}
