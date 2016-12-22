//
//  MenuScene.swift
//  SpaceGame
//
//  Created by Xin Zou on 12/20/16.
//  Copyright © 2016 Xin Zou. All rights reserved.
//

import SpriteKit
import AVFoundation

class MenuScene: SKScene {

    var musicPlayer : AVAudioPlayer!
    var starField:SKEmitterNode!
    
    var titleLabel:     SKLabelNode!
    var startButton:    SKSpriteNode!
    var difficultyButton:SKSpriteNode!
    var difficultyLabel: SKLabelNode!
    var loginSignupButton: SKSpriteNode!
    var loginSignupLabel: SKLabelNode!
    
    var difficulitySelected : Int!
    let difficulity: [Int:String] = [
        1 : "Easy",
        2 : "Normal",
        3 : "Heard",
        4 : "Survival"
    ]
    
    func addButton(named:String, yFromTop:CGFloat) -> SKSpriteNode {
        let button = SKSpriteNode(imageNamed: "button_blue_frame")
        button.size = CGSize(width: 270, height: 60)
        button.position = CGPoint(x: self.frame.midX, y: yFromTop)
        button.zPosition = 0
        button.name = named
        self.addChild(button)
        
        return button
    }
    
    func addLabel(text:String, atPosition pos: CGPoint) -> SKLabelNode {
        
        var label = SKLabelNode(text: text)
        label.name = text
        label.fontColor = UIColor.white
        label.fontSize = 30
        label.fontName = "Courier Bold"// "AmericanTypewriter"
        label.position = CGPoint(x: pos.x, y:pos.y - 10)
        label.zPosition = 1
        self.addChild(label)
        
        return label
    }

    func gameMusicSetup(){
        let bgmName = "Vaikings"
        
        let audioPath = Bundle.main.path(forResource: bgmName, ofType: "mp3")
        do {
            try musicPlayer = AVAudioPlayer(contentsOf: URL(fileURLWithPath: audioPath!))
//            musicPlayer.volume = 0.8
            musicPlayer.play()
        }catch{
            print("unable to load music file: GameScene.swift:170")
        }
        
    }
    

    
    override func didMove(to view: SKView) {
        
        gameMusicSetup()
        
//        starField = self.childNode(withName: "starField") as! SKEmitterNode
        starField = SKEmitterNode(fileNamed: "Starfield")
        starField.position = CGPoint(x: self.frame.midX, y: self.frame.maxY)
        starField.zPosition = -1
        starField.advanceSimulationTime(10)
        self.addChild(starField)
        
        titleLabel = addLabel(text: "SPACE EPIC", atPosition: CGPoint(x: self.frame.midX, y: 550))
        titleLabel.fontColor = UIColor.yellow
        titleLabel.fontSize = 46
        
        startButton = addButton(named: "startButton", yFromTop: 420)
        _ = addLabel(text: "START", atPosition: startButton.position)
        
        if difficulitySelected == nil || difficulitySelected == 0 {
            difficulitySelected = 1
        }
        let diffText = difficulity[difficulitySelected] as String!
        difficultyButton = addButton(named: "difficulityButton", yFromTop: startButton.position.y - 90)
        difficultyLabel  = addLabel(text: diffText!, atPosition: difficultyButton.position)
        difficultyLabel.name = "Easy"
        
        loginSignupButton = addButton(named: "Login/Signup", yFromTop: difficultyButton.position.y - 90)
        loginSignupLabel  = addLabel(text: "Login/Signup", atPosition: loginSignupButton.position)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        
        if let location = touch?.location(in: self) {
            let nodesArray = self.nodes(at: location)
            
            if nodesArray.first?.name == "startButton" || nodesArray.first?.name == "START" {
                self.musicPlayer?.pause()
                let transition = SKTransition.flipHorizontal(withDuration: 0.5)
                let gameScene = SKScene(fileNamed: "GameScene") as! GameScene
                gameScene.difficulity = difficulitySelected
                self.view?.presentScene(gameScene, transition: transition)
            }else
            if nodesArray.first?.name == "difficulityButton" || nodesArray.first?.name == "Easy" {
                changeDifficulity()
            }else
            if nodesArray.first?.name == "Login/Signup" { // button and Label have the same name:
                // go to login page;
            }
        }
    }
    
    func changeDifficulity(){
        if var diff = difficulitySelected as Int? {
            diff += 1
            if diff > difficulity.count {
                diff = 1
            }
            difficultyLabel.text = difficulity[diff]! as String!
            difficulitySelected = diff
        }else{
            difficulitySelected = 1
        }
    }
}
