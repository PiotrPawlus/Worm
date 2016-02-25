//
//  PauseMenu.swift
//  Worm
//
//  Created by Piotr Pawluś on 18/02/16.
//  Copyright © 2016 Piotr Pawluś. All rights reserved.
//

import SpriteKit

class PauseMenu: SKSpriteNode {

    private var pauseMenuSize: CGSize!
    private weak var delegate: SKScene!
    static var gamePaused: Bool = false
    
    // MARK: - initializers
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(imageNamed: String, frameSize: CGSize, delegate: SKScene) {
  
        let texture = SKTexture(imageNamed: imageNamed)
        
        self.delegate = delegate
    
        pauseMenuSize = CGSize(width: texture.size().width, height: texture.size().height)
        super.init(texture: texture, color: UIColor.clearColor(), size: pauseMenuSize)
        self.position = CGPointMake(frameSize.width / 2, frameSize.height / 2)
        self.zPosition = ObjectsZPositions.hud
        PauseMenu.gamePaused = true
        
        self.setPlayButton()
        self.setReloadyButton()
        self.setMenuButton()
    }
    
    // MARK: - Pause menu objects
    func setPlayButton() {
        let playBtn = SKButton(defaultButtonImage: "PlayButton", activeButtonImage: "PlayButtonShadow", buttonAction: playButton)
        playBtn.zPosition = ObjectsZPositions.hudObjects

        playBtn.position = CGPointMake(0 - (self.pauseMenuSize.width * 2/7), 0 - (self.pauseMenuSize.height * 1/7))
        self.addChild(playBtn)
    }
    
    func setReloadyButton() {
        let reloadBtn = SKButton(defaultButtonImage: "ReloadButton", activeButtonImage: "ReloadButton", buttonAction: reloadScene)
        reloadBtn.zPosition = ObjectsZPositions.hudObjects

        reloadBtn.position = CGPointMake(0, 0 - (self.pauseMenuSize.height * 1/7))
        self.addChild(reloadBtn)
    }
    
    func setMenuButton() {
        let menuBtn = SKButton(defaultButtonImage: "MenuButton", activeButtonImage: "MenuButtonShadow", buttonAction: goToMenu)
        menuBtn.zPosition = ObjectsZPositions.hudObjects
        
        menuBtn.position = CGPointMake(0 + (self.pauseMenuSize.width * 2/7), 0 - (self.pauseMenuSize.height * 1/7))
        self.addChild(menuBtn)
    }
    
    // MARK: - Buttons actions
    func playButton() {
        self.removeFromParent()
        if self.delegate is GameScene {
            (self.delegate as! GameScene).unpauseWorm = true
        } else if self.delegate is GameSceneMP {
            (self.delegate as! GameSceneMP).unpauseWorm = true
        }
        PauseMenu.gamePaused = false
    }
    
    func reloadScene() {
        self.delegate?.view!.presentScene(GameScene(size: (self.delegate?.size)!), transition: SKTransition.fadeWithDuration(0.5))
    }
    
    func goToMenu() {
        self.delegate?.view!.presentScene(MenuScene(size: (self.delegate?.size)!), transition: SKTransition.fadeWithDuration(0.5))
    }
    
}
