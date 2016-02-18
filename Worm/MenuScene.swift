//
//  MenuScene.swift
//  Worm
//
//  Created by Piotr Pawluś on 18/02/16.
//  Copyright © 2016 Piotr Pawluś. All rights reserved.
//

import SpriteKit

class MenuScene: SKScene {
    
    // MARK: - Presenting a Scene
    override func didMoveToView(view: SKView) {

        self.background()
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
    
    func bigPlayButton() {
        
    }
}
