//
//  SKButton.swift
//  Worm
//
//  Created by Piotr Pawluś on 18/02/16.
//  Copyright © 2016 Piotr Pawluś. All rights reserved.
//
import SpriteKit

class SKButton: SKNode {
    var defaultButton: SKSpriteNode
    var activeButton: SKSpriteNode
    var disabledButton: SKSpriteNode!
    var action: () -> Void
    var enabled: Bool {
        get {
            return userInteractionEnabled
        }
        set {
            switch newValue {
            case true:
                userInteractionEnabled = true
                defaultButton.hidden = false
                activeButton.hidden = true
                if disabledButton != nil {
                    disabledButton.hidden = true
                }
            case false:
                userInteractionEnabled = false
                activeButton.hidden = true
                if disabledButton != nil {
                    defaultButton.hidden = true
                    disabledButton.hidden = false
                } else {
                    defaultButton.hidden = false
                }
            }
        }
    }
    
    init(defaultButtonImage: String, activeButtonImage: String, buttonAction: () -> Void) {
        defaultButton = SKSpriteNode(imageNamed: defaultButtonImage)
        activeButton = SKSpriteNode(imageNamed: activeButtonImage)
        disabledButton = nil
        
        activeButton.hidden = true
        action = buttonAction
        super.init()
        
        self.enabled = true
        userInteractionEnabled = true
        addChild(defaultButton)
        addChild(activeButton)
    }
    
    init(defaultButtonImage: String, activeButtonImage: String, disabledButtonImage: String, buttonAction: () -> Void) {
        defaultButton = SKSpriteNode(imageNamed: defaultButtonImage)
        activeButton = SKSpriteNode(imageNamed: activeButtonImage)
        disabledButton = SKSpriteNode(imageNamed: disabledButtonImage)
        
        activeButton.hidden = true
        disabledButton.hidden = true
        action = buttonAction
        super.init()
        
        self.enabled = true
        userInteractionEnabled = true
        addChild(defaultButton)
        addChild(activeButton)
        addChild(disabledButton)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if enabled {
            activeButton.hidden = false
            defaultButton.hidden = true
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch: UITouch = touches.first! as UITouch
        let location: CGPoint = touch.locationInNode(self)
        
        if defaultButton.containsPoint(location) {
            activeButton.hidden = false
            defaultButton.hidden = true
        } else {
            activeButton.hidden = true
            defaultButton.hidden = false
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch: UITouch = touches.first! as UITouch
        let location: CGPoint = touch.locationInNode(self)
        
        if defaultButton.containsPoint(location) {
            action()
        }
        
        activeButton.hidden = true
        defaultButton.hidden = false
    }
    
    
}


  