//
//  GameOverScene.swift
//  SpaceGame
//
//  Created by Xin Zou on 12/21/16.
//  Copyright © 2016 Xin Zou. All rights reserved.
//

import SpriteKit

class GameOverScene: SKScene {
    
    let fontName : String = "AmericanTypewriter"
    let fontNameB: String = "AmericanTypewriter-Bold"

    var starField: SKEmitterNode!
    var gameOverLabel: SKLabelNode!
    var scoreLabel: SKLabelNode!
    var score: Int = 1 // default value
    var difficulity: Int!
    
    var newGameLabel:   SKLabelNode!
    var newGameButton:  SKSpriteNode!
    var menuLabel:      SKLabelNode!
    var menuButton:     SKSpriteNode!
    
    
    override func didMove(to view: SKView) {
        
        if difficulity == nil {
            difficulity = 1
        }
        
        starField = SKEmitterNode(fileNamed: "Starfield")
        starField.position = CGPoint(x: self.frame.midX, y: self.frame.maxY)
        starField.zPosition = -1
        starField.advanceSimulationTime(10)
        self.addChild(starField)
        
        gameOverLabel = SKLabelNode(text: "GAME OVER")
        gameOverLabel.fontSize = 46
        gameOverLabel.fontName = fontNameB
        gameOverLabel.fontColor = UIColor.yellow
        gameOverLabel.position = CGPoint(x: self.frame.midX, y: 500)
        self.addChild(gameOverLabel)
        
        scoreLabel = SKLabelNode(text: "Your score: \(score)")
        scoreLabel.fontSize = 36
        scoreLabel.fontName = fontName
        scoreLabel.fontColor = UIColor.white
        scoreLabel.position = CGPoint(x: self.frame.midX, y: 430)
        self.addChild(scoreLabel)
        
        newGameButton = SKSpriteNode(imageNamed: "button_blue_frame")
        newGameButton.size = CGSize(width: 270, height: 60)
        newGameButton.position = CGPoint(x: self.frame.midX, y: 380)
        newGameButton.name = "newGameButton"
        self.addChild(newGameButton)
        
        newGameLabel = SKLabelNode(text: "Fight Again")
        newGameLabel.name = "newGameLabel"
        newGameLabel.fontSize = 30
        newGameLabel.fontName = fontName
        newGameLabel.fontColor = UIColor.white
        newGameLabel.position = CGPoint(x: self.frame.midX, y: newGameButton.position.y - 10)
        newGameLabel.zPosition = 1
        self.addChild(newGameLabel)
        
        menuButton = SKSpriteNode(imageNamed: "button_blue_frame")
        menuButton.size = CGSize(width: 270, height: 60)
        menuButton.position = CGPoint(x:self.frame.midX, y:newGameButton.position.y - 100)
        menuButton.name = "menuButton"
        self.addChild(menuButton)
        
        menuLabel = SKLabelNode(text: "MENU")
        menuLabel.name = "menuLabel"
        menuLabel.fontSize = 30
        menuLabel.fontName = fontName
        menuLabel.fontColor = UIColor.white
        menuLabel.position = CGPoint(x: self.frame.midX, y: menuButton.position.y - 10)
        menuLabel.zPosition = 1
        self.addChild(menuLabel)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let location = touches.first?.location(in: self)
        let transit = SKTransition.flipHorizontal(withDuration: 0.5)
        
        let nodesArr = self.nodes(at: location!)
        if nodesArr.first?.name == "newGameLabel" || nodesArr.first?.name == "newGameButton" {
            let gameScene = GameScene(size: self.size)
            gameScene.score = 0
            gameScene.difficulity = difficulity
            self.view!.presentScene(gameScene, transition: transit)
        }else
        if nodesArr.first?.name == "menuLabel" || nodesArr.first?.name == "menuButton" {
            let menuScene = MenuScene(size: self.size)
            self.view!.presentScene(menuScene, transition: transit)
        }
        
    }
    
    
    
}
