//
//  MenuScene.swift
//  SpaceGame
//
//  Created by Xin Zou on 12/20/16.
//  Copyright © 2016 Xin Zou. All rights reserved.
//

import UIKit
import SpriteKit
import AVFoundation

class MenuScene: SKScene, UITextFieldDelegate {

    var musicPlayer : AVAudioPlayer!
    var starField:SKEmitterNode!
    
    var titleLabel:     SKLabelNode!
    var startButton:    SKSpriteNode!
    var difficultyButton:SKSpriteNode!
    var difficultyLabel: SKLabelNode!
    var loginPageButton: SKSpriteNode!
    var loginPageLabel:  SKLabelNode!

    // put LoginSignup nodes at the RIGHT side of self.view
    var loginPageTitle:SKLabelNode!
    var usernameTextField: UITextField!
    var passwordTextField: UITextField!
    var loginSignupBtn: SKSpriteNode!
    var loginSignupLabel:SKLabelNode!
    var changeHintLabel: SKLabelNode!
    var changeLoginLabel:SKLabelNode!
    var backButton: SKLabelNode!
    var isLoginMode = true {
        didSet {
            if isLoginMode {
                loginSignupLabel?.text = "Login"
                changeHintLabel?.text = "New Friend? "
                changeLoginLabel?.text = "Sign Up"
            }else{
                loginSignupLabel?.text = "Sign Up"
                changeHintLabel?.text = "Old Friend? "
                changeLoginLabel?.text = "Login"
            }
        }
    }

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

    func addTextField(placeHolder:String, isPassword:Bool, positionY y:CGFloat) -> UITextField {
        let width:CGFloat = 260
        let xPos = self.view!.frame.midX - width / 2
        var field = UITextField(frame: CGRect(x: xPos, y: y, width: width, height: 40) )

        if isPassword {
            field.keyboardType = .asciiCapable
        }else{ // be username:
            field.keyboardType = .emailAddress
        }
        field.delegate = self
        field.borderStyle = .roundedRect
        field.textColor = UIColor.black
        field.backgroundColor = UIColor.white
        field.placeholder = placeHolder
        field.autocorrectionType = .no
        field.autocapitalizationType = .none
        field.isSecureTextEntry = isPassword
        field.clearButtonMode = UITextFieldViewMode.whileEditing // !!!
        field.layer.zPosition = 1
        self.view!.addSubview(field)
        
        return field
    }
    // called when tapping return:
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // hide keyboard:
        textField.resignFirstResponder()
        
        return true
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
    
    func moveTextField(toShow:Bool, timeInterval: TimeInterval){
        if toShow {
            usernameTextField.isHidden = !toShow
            passwordTextField.isHidden = !toShow
            usernameTextField.alpha = 0
            passwordTextField.alpha = 0
            UIView.animate(withDuration: timeInterval, animations: {
                self.usernameTextField.alpha = 1
                self.passwordTextField.alpha = 1
            })
        }else{
            UIView.animate(withDuration: timeInterval, animations: { 
                self.usernameTextField.alpha = 0
                self.passwordTextField.alpha = 0
            }, completion: { (Bool) in
                self.usernameTextField.isHidden = !toShow
                self.passwordTextField.isHidden = !toShow
            })
        }
    }
    func moveSceneTo(right:Bool, duration dur:TimeInterval) {
        moveTextField(toShow: right, timeInterval: dur)
        var offSet = self.size.width
        if right {
            offSet = -offSet
        }
        for node in self.children {
            if node.name != "Starfield" { // do NOT move background;
                node.run(SKAction.move(by: CGVector(dx: offSet, dy: 0), duration: dur) )
            }
        }
    }

    
    override func didMove(to view: SKView) {
        
        gameMusicSetup()
        
        let midX = self.frame.midX
        
        // set up for menu page: =============================================
        // starField = self.childNode(withName: "starField") as! SKEmitterNode
        starField = SKEmitterNode(fileNamed: "Starfield")
        starField.name = "Starfield"
        starField.position = CGPoint(x: midX, y: self.frame.maxY)
        starField.zPosition = -1
        starField.advanceSimulationTime(10)
        self.addChild(starField)
        
        titleLabel = addLabel(text: "SPACE EPIC", atPosition: CGPoint(x: midX, y: 550))
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
        
        loginPageButton = addButton(named: "Login/Signup", yFromTop: difficultyButton.position.y - 90)
        loginPageLabel  = addLabel(text: "Login/Signup", atPosition: loginPageButton.position)
        
        // set up for Login page: ============================================
        let loginPageX = (self.size.width / 2) * 3
        
        loginPageTitle = addLabel(text: "Hi~Captian!", atPosition: CGPoint(x: loginPageX, y:titleLabel.position.y))
        loginPageTitle.fontColor = titleLabel.fontColor
        loginPageTitle.fontSize = titleLabel.fontSize
        
        usernameTextField = addTextField(placeHolder: "Email/username", isPassword: false, positionY: 230)
        passwordTextField = addTextField(placeHolder: "password", isPassword: true, positionY: 290)
        usernameTextField.isHidden = true
        passwordTextField.isHidden = true
        
        loginSignupBtn = addButton(named: "Login", yFromTop: loginPageButton.position.y)
        loginSignupBtn.position.x = loginPageX
        loginSignupLabel = addLabel(text: "Login", atPosition: loginSignupBtn.position)
        
        changeHintLabel = addLabel(text: "Hint", atPosition: CGPoint(x:loginPageX - 60, y:180))
        changeLoginLabel = addLabel(text: "ChangeMode", atPosition: CGPoint(x:loginPageX + 60, y:180))
        // itself also functioning as button to "change".
        changeHintLabel.text = "New friend? "
        changeLoginLabel.text = "SignUp"
        changeHintLabel.fontSize = 20
        changeLoginLabel.fontSize = 20
        changeLoginLabel.fontColor = UIColor.cyan
        
        backButton = addLabel(text: "Back", atPosition: CGPoint(x:loginPageX - 150, y:620))
        backButton.fontSize = 35
        backButton.text = "💫"
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        
        if let location = touch?.location(in: self) {
            let nodesArray = self.nodes(at: location)
            let transition = SKTransition.flipVertical(withDuration: 0.5)
            
            if nodesArray.first?.name == "startButton" || nodesArray.first?.name == "START" {
                musicPlayer.stop()
                let gameScene = SKScene(fileNamed: "GameScene") as! GameScene
                gameScene.difficulity = difficulitySelected
                self.view?.presentScene(gameScene, transition: transition)
            }else
            if nodesArray.first?.name == "difficulityButton" || nodesArray.first?.name == "Easy" {
                changeDifficulity()
            }else
            if nodesArray.first?.name == "Login/Signup" { // button and Label have the same name:
                moveSceneTo(right: true, duration: 0.5)
            }else
            if nodesArray.first?.name == "Back" {
                moveSceneTo(right: false, duration: 0.5)
            }else
            if nodesArray.first?.name == "Login" {
                if isLoginMode {
                    // do login by username
                }else{
                    // do signup by username
                }
            }else
            if nodesArray.first?.name == "ChangeMode" {
                isLoginMode = !isLoginMode
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
