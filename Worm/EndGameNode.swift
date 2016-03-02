//
//  EndGameNode.swift
//  Worm
//
//  Created by Piotr Pawluś on 19/02/16.
//  Copyright © 2016 Piotr Pawluś. All rights reserved.
//

import SpriteKit

class EndGameNode: SKSpriteNode {

    private weak var delegate: SKScene!
    private var endGameSize: CGSize!
    static var endGame: Bool = false
    
    // MARK: - initializers
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(imageNamed: String, delegate: SKScene) {
        
        self.delegate = delegate
        
        let texture = SKTexture(imageNamed: imageNamed)
        endGameSize = texture.size()
        super.init(texture: texture, color: UIColor.clearColor(), size: endGameSize)
        self.setScale(0.8)
        self.zPosition = ObjectsZPositions.hud

        self.setMenuButton()
        self.setPlayAgain()
    }
    
    func setMenuButton() {
        let menuBtn = SKButton(defaultButtonImage: "MenuButton", activeButtonImage: "MenuButtonShadow") { () -> Void in
            self.delegate?.view!.presentScene(MenuScene(size: (self.delegate?.size)!), transition: SKTransition.fadeWithDuration(0.5))

            self.delegate?.removeAllActions()
            self.delegate?.removeAllChildren()
            self.delegate?.removeFromParent()
            
            EndGameNode.endGame = true
        }
        menuBtn.zPosition = ObjectsZPositions.hudObjects
        menuBtn.position = CGPointMake(-(self.endGameSize.width * 1/7), -(self.endGameSize.height * 3/7))
        self.addChild(menuBtn)
    }
    
    func setPlayAgain() {
        let playAgainBtn = SKButton(defaultButtonImage: "Accept", activeButtonImage: "AcceptShadow") { () -> Void in
            self.delegate?.view!.presentScene(GameScene(size: (self.delegate?.size)!), transition: SKTransition.fadeWithDuration(0.5))
            
            self.delegate?.removeAllActions()
            self.delegate?.removeAllChildren()
            self.delegate?.removeFromParent()
            EndGameNode.endGame = true
        }
        playAgainBtn.zPosition = ObjectsZPositions.hudObjects
        playAgainBtn.position =  CGPointMake((self.endGameSize.width * 1/7), -(self.endGameSize.height * 3/7))
        self.addChild(playAgainBtn)
    }

}
