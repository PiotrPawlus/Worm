//
//  GameViewController.swift
//  Worm
//
//  Created by Piotr Pawluś on 17/02/16.
//  Copyright (c) 2016 Piotr Pawluś. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        let skView = self.view as! SKView
        

        
        let scene = MenuScene(size: skView.bounds.size)
        scene.scaleMode = .AspectFit
        skView.presentScene(scene)
    }
    
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return .AllButUpsideDown
        } else {
            return .All
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
