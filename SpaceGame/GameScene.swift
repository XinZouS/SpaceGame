//
//  GameScene.swift
//  SpaceGame
//
//  Created by Xin Zou on 12/20/16.
//  Copyright © 2016 Xin Zou. All rights reserved.
//

import SpriteKit
import GameplayKit
import CoreMotion
import AVFoundation

class GameScene: SKScene, SKPhysicsContactDelegate {

    let fontName : String = "AmericanTypewriter"
    let fontNameB: String = "AmericanTypewriter-Bold"
    
    var gameTimer: Timer!
    var difficulity: Int!
    
    var musicPlayer : AVAudioPlayer!
    
    var starField: SKEmitterNode!
    var player: SKSpriteNode!
    var livesArray = [SKSpriteNode]()
    
    var quitLabel = SKLabelNode()
    var scoreLabel = SKLabelNode()
    var score : Int = 0 {
        didSet{
            scoreLabel.text = "\(score)"
        }
    }
    
    var yOffset : CGFloat! // for aliens do NOT overlap, or it will caus nullptr;
    var possibleAliens = ["alien1","alien2","alien3"]
    var BGMs = ["Vaikings", "DamageDealers", "Varjag_WOWships", "WrathOfPoseidon_WOWships"]

    let torpedoCategory: UInt32 = 0x01 << 1
    let alienCategory:   UInt32 = 0x01 << 2
    
    let motionManger = CMMotionManager()
    var xAcceleration : CGFloat = 0
    
    
    override func didMove(to view: SKView) {
        
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        self.physicsWorld.contactDelegate = self

        if difficulity == nil || difficulity == 0 {
            difficulity = 1
        }
        yOffset = 0
        
        var alienT : TimeInterval = 0.8
        if let getDifficulity = difficulity {
            alienT -= (Double(getDifficulity) * 0.15)
        }
        // add Alien:
        gameTimer = Timer.scheduledTimer(timeInterval: alienT, target: self, selector: #selector(addAlien), userInfo: nil, repeats: true)
        
        gameMusicSetup()
        
        addLives()

        starField = SKEmitterNode(fileNamed: "Starfield")
        starField.position = CGPoint(x: self.frame.midX, y: self.frame.maxY)
        starField.advanceSimulationTime(10)
        starField.zPosition = -1
        self.addChild(starField)

        player = SKSpriteNode(imageNamed: "Spaceship")
        player.position = CGPoint(x: self.frame.midX, y: 80)
        player.size = CGSize(width: 60, height: 60)
        self.addChild(player)
        
        quitLabel = SKLabelNode(text: "❎")
        quitLabel.name = "QuitLabel"
        quitLabel.fontSize = 35
        quitLabel.position = CGPoint(x: 35, y: self.frame.maxY - 50)
        quitLabel.zPosition = 1
        self.addChild(quitLabel)
        
        scoreLabel = SKLabelNode(text: "0")
        scoreLabel.fontName = fontNameB
        scoreLabel.fontSize = 50
        scoreLabel.position = CGPoint(x: self.frame.maxX - 50, y: self.frame.maxY - 100)
        scoreLabel.zPosition = 1
        scoreLabel.color = UIColor.cyan
        self.addChild(scoreLabel)
        
        // move player by CoreMotion: =================================================
        motionManger.accelerometerUpdateInterval = 0.2
        motionManger.startAccelerometerUpdates(to: OperationQueue.current!) { (data:CMAccelerometerData?, err:Error?) in
            if let accelectionData = data {
                let accelection = accelectionData.acceleration
                self.xAcceleration = CGFloat(accelection.x) * 0.6 + self.xAcceleration * 0.25
            }
        }
    }
    
    func addLives(){
        for live in 1...4 {
            let node = SKSpriteNode(imageNamed: "Spaceship")
            node.size = CGSize(width: 40, height: 40)
            node.position = CGPoint(x: self.frame.width - 10 - CGFloat(live) * node.size.width, y: self.frame.height - 30)
            node.zPosition = 1
            livesArray.append(node)
            self.addChild(node)
        }
    }
    
    func addAlien() {
        possibleAliens = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: possibleAliens) as! [String]
        
        let alien = SKSpriteNode(imageNamed: possibleAliens[0])
        
        let randomAlienPosition = GKRandomDistribution(lowestValue: 5, highestValue: Int(self.frame.width) - 5)
        let xPosition = CGFloat(randomAlienPosition.nextInt())
        yOffset = yOffset + 10
        if yOffset > 100 {
            yOffset = 0
            // and , check (not too frequently) the BGM playing: 
            if !musicPlayer.isPlaying {
                gameMusicSetup()
            }
        }
        
        alien.position = CGPoint(x: xPosition, y: self.frame.height + yOffset)
        alien.physicsBody = SKPhysicsBody(rectangleOf: alien.size)
        alien.physicsBody?.isDynamic = true
        alien.physicsBody?.categoryBitMask = alienCategory
        alien.physicsBody?.collisionBitMask = 0
        alien.physicsBody?.contactTestBitMask = torpedoCategory
        self.addChild(alien)
        
        // remove lives when alien hits bottom(removed out of screen):
        let movingDuration: TimeInterval = 6
        var actions = [SKAction]()
        actions.append(SKAction.move(to: CGPoint(x: alien.position.x, y: -alien.size.height), duration: movingDuration))
        actions.append(SKAction.run { // if alien touches bottom line: (following by movingDuration)
            self.run(SKAction.playSoundFileNamed("sms-alert-5.mp3", waitForCompletion: false))
            if self.livesArray.count > 0 {
                if let node = self.livesArray.last as SKSpriteNode? {
                    node.removeFromParent()
                    self.livesArray.removeLast()
                }
                
                if self.livesArray.count == 0 {
                    self.musicPlayer.stop()
                    let transition = SKTransition.flipHorizontal(withDuration: 0.5)
                    let gameOver = SKScene(fileNamed: "GameOverScene") as! GameOverScene
                    gameOver.score = self.score
                    gameOver.difficulity = self.difficulity
                    self.view!.presentScene(gameOver, transition: transition)
                }
            }
        })
        actions.append(SKAction.removeFromParent())
        alien.run(SKAction.sequence(actions))
        
    }
    
    func fireTorpeto() {
        self.run(SKAction.playSoundFileNamed("torpedo.mp3", waitForCompletion: false)) //true or false doesnt seen different...
        
        let torpedo = SKSpriteNode(imageNamed: "torpedo")
        torpedo.position = player.position
        torpedo.position.y += 15
        torpedo.physicsBody = SKPhysicsBody(circleOfRadius: torpedo.size.height / 2)
        torpedo.physicsBody?.isDynamic = true
        torpedo.physicsBody?.categoryBitMask = torpedoCategory
        torpedo.physicsBody?.collisionBitMask = 0
        torpedo.physicsBody?.contactTestBitMask = alienCategory
        torpedo.physicsBody?.usesPreciseCollisionDetection = true // detact location of the collision happend !!!!!!
        self.addChild(torpedo)
        
        var actions = [SKAction]()
        actions.append(SKAction.move(to: CGPoint(x: torpedo.position.x, y: self.frame.height + 30), duration: 0.3))
        actions.append(SKAction.removeFromParent())
        torpedo.run(SKAction.sequence(actions))
    }
    
    func gameMusicSetup(){
        var bgmName = "Vaikings" // set a default name
        let bgmNum = Int(arc4random() % UInt32(BGMs.count))
        bgmName = BGMs[bgmNum] as! String
        
        let audioPath = Bundle.main.path(forResource: bgmName, ofType: "mp3")
        do {
            try musicPlayer = AVAudioPlayer(contentsOf: URL(fileURLWithPath: audioPath!))
            musicPlayer.play()
        }catch{
            print("unable to load music file: GameScene.swift:190")
        }
        
    }
    
    // move player by CoreMotion: =======================================
    override func didSimulatePhysics() {
        player.position.x += xAcceleration * 50
        
        player.position.x = max(player.position.x, 10)
        player.position.x = min(player.position.x, self.frame.width - 10)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let location = touches.first?.location(in: self)
        
        if let nodeArray = self.nodes(at: location!) as [SKNode]? {
            if nodeArray.first?.name == "QuitLabel" {
                self.musicPlayer?.stop()
                let transition = SKTransition.flipHorizontal(withDuration: 0.5)
                let menuScene = MenuScene(size: self.size)
                menuScene.difficulitySelected = self.difficulity
                self.view?.presentScene(menuScene, transition: transition)
            }else{
                fireTorpeto()
            }
        }
        
    }
    
    
    // detact contact between nodes:
    func didBegin(_ contact: SKPhysicsContact) {
        var firstBody: SKPhysicsBody!
        var secondBody: SKPhysicsBody!
        
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody  = contact.bodyA // torpedo == 1
            secondBody = contact.bodyB // alien == 2
        }else{
            firstBody  = contact.bodyB // torpedo == 1
            secondBody = contact.bodyA // alien == 2
        }
        
        if ((firstBody.categoryBitMask & torpedoCategory) != 0) && ((secondBody.categoryBitMask & alienCategory) != 0) {
            if firstBody.node != nil && secondBody.node != nil {
                torpedoHitsAlien(torpedo: (firstBody.node as? SKSpriteNode)!, alien: (secondBody.node as? SKSpriteNode)!)
            }
        }
    }
    
    
    func torpedoHitsAlien(torpedo: SKSpriteNode, alien: SKSpriteNode){
        score += 1
        
        let explosion = SKEmitterNode(fileNamed: "Explosion")!
        explosion.position = alien.position
        self.addChild(explosion)
        
        self.run(SKAction.playSoundFileNamed("explosion.mp3", waitForCompletion: false))
        
        torpedo.removeFromParent()
        alien.removeFromParent()
        
        self.run(SKAction.wait(forDuration: 2)) { 
            explosion.removeFromParent()
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
