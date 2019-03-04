//
//  GameOverScene.swift
//  EndlessRunner
//
//  Created by Himauli Patel on 2019-03-03.
//  Copyright © 2019 Himauli Patel. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit

    class GameOverScene: SKScene{
        var playerWin = true
       init(size: CGSize, win:Bool) {
        super.init(size: size)
        self.playerWin = win
    }

//----------
//required nonsense to make this class work
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func didMove(to view: SKView) {
        
        if (playerWin == true)
        {
            let winSound = SKAction.playSoundFileNamed("BackgroundMusic/Win.wav",waitForCompletion: false)
            self.run(winSound)
            
            let message = SKLabelNode(text:"Winner!!!")
            message.position = CGPoint(x:self.size.width/2, y:self.size.height/2)
            message.fontSize = 75
            message.fontName = "Chalkduster"
            message.fontColor = UIColor.white
            addChild(message)
        }
        else
        {
            let gameOverSound = SKAction.playSoundFileNamed("BackgroundMusic/GameOver.wav",waitForCompletion: false)
            self.run(gameOverSound)
            
            let message = SKLabelNode(text:"Game Over!")
            message.position = CGPoint(x:self.size.width/2, y:self.size.height/2)
            message.fontSize = 75
            message.fontName = "Chalkduster"
            message.fontColor = UIColor.white
            addChild(message)
        }
        
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // When person touches screen, send them back to the game
        
        // 1. Initialize the new scene
        let gameScene = GameScene(size:self.size)
        gameScene.scaleMode = self.scaleMode
        
        // 2. Configure the "animation" between screens
        let transitionEffect = SKTransition.flipHorizontal(withDuration: 3)
        
        // 3. Show the scene
        self.view?.presentScene(gameScene, transition: transitionEffect)
        }
}
