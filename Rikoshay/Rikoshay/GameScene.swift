//
//  GameScene.swift
//  Rikoshay
//
//  Created by Patrick O'Brien on 8/22/17.
//  Copyright © 2017 Patrick O'Brien. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    var Mainball = SKSpriteNode(imageNamed: "RikoshayBall")
    
   
    override func didMove(to view: SKView) {
        Mainball.size = CGSize(width: 30, height: 30)
        Mainball.position = CGPoint(x: frame.width / 2, y: frame.height / 2)
        print(Mainball.position)
        print(frame.width, frame.height)
        self.addChild(Mainball)
    }
    
    
 
    
}
