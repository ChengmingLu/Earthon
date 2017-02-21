//
//  GameScene.swift
//  Earthon
//
//  Created by Fumlar on 2017-02-20.
//  Copyright © 2017 Fumlar. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    var touchInProgress = false
    var gameInProgress = false
    var earth = SKSpriteNode()
    var earthShield = SKSpriteNode()
    var startButton = SKSpriteNode()
    var timerLabel = SKLabelNode()
    var scoreLabel = SKLabelNode()
    var separatorLabel = SKLabelNode()
    //var rock = SKSpriteNode()
    var rockTexture = SKTexture()
    var timerNode = SKNode()
    var rockVelocity = CGFloat()
    var rockSpawnInterval = TimeInterval(5.0)
    var halfFrameDiagnal = CGFloat()
    var dynamicDifficulty = CGFloat()
    var timer = CGFloat(0)
    var diagnalAngle = CGFloat()
    let objectRelativeScale = CGFloat(0.0002)
    let rockVelocityScale = CGFloat(0.3)
    let initialShieldOffset = CGFloat(-1.82)
    let rotationAngle = CGFloat(M_PI / 32)
    let rotationDuration = TimeInterval(3)
    let timerLabelYPosOffset = CGFloat(6)
    let scoreLabelYPosOffset = CGFloat(-40)
    let separatorLabelYPosOffset = CGFloat(-3)
    
    enum CollisionType: UInt32 {
        case Rock = 1
        case Shield = 2
        case Earth = 4
    }
    
    override func didMove(to view: SKView) {
        self.physicsWorld.contactDelegate = self
        halfFrameDiagnal = sqrt(pow(self.frame.size.width / 2, 2) + pow(self.frame.size.height / 2, 2))
        diagnalAngle = tanh(self.frame.size.width / self.frame.size.height)
        
        //timerNode.zPosition = -1
        //testing
        //let testEarth = SKShapeNode(circleOfRadius: 10)
        //testEarth.fillColor = SKColor.green
        //testEarth.strokeColor = SKColor.clear
        //testEarth.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        //finished testing
        
        let earthTexture = SKTexture(imageNamed: "EarthFG.png")
        let earthShieldTexture = SKTexture(imageNamed: "EarthShieldSingle.png")
        let startButtonTexture = SKTexture(imageNamed: "StartButton.png")
        rockTexture = SKTexture(imageNamed: "Rock.png")
        
        earth = SKSpriteNode(texture: earthTexture)
        earthShield = SKSpriteNode(texture: earthShieldTexture)
        startButton = SKSpriteNode(texture: startButtonTexture)
        
        timerLabel = SKLabelNode(fontNamed: "AppleSDGothicNeo-Regular")
        scoreLabel = SKLabelNode(fontNamed: "AppleSDGothicNeo-Regular")
        separatorLabel = SKLabelNode(fontNamed: "AppleSDGothicNeo-Bold")
        timerLabel.text = "60"
        scoreLabel.text = "0"
        separatorLabel.text = "___"
        
        earth.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        earth.zPosition = 4
        earthShield.position = earth.position
        earthShield.zPosition = 3
        startButton.position = earth.position
        startButton.zPosition = 5
        timerNode.zPosition = -1
        timerLabel.position = earth.position
        timerLabel.position.y += timerLabelYPosOffset
        timerLabel.zPosition = 6
        scoreLabel.position = earth.position
        scoreLabel.position.y += scoreLabelYPosOffset
        scoreLabel.zPosition = 6
        separatorLabel.position = earth.position
        separatorLabel.position.y += separatorLabelYPosOffset
        separatorLabel.zPosition = 6
        earth.setScale(self.frame.size.width * objectRelativeScale)
        earthShield.setScale(earth.xScale)
        startButton.setScale(earth.xScale)
        
        earthShield.zRotation = initialShieldOffset
        earth.physicsBody = SKPhysicsBody(circleOfRadius: earth.size.width / 2, center: earth.position)
        earth.physicsBody!.isDynamic = false
        earth.physicsBody!.categoryBitMask = CollisionType.Earth.rawValue
        earth.physicsBody!.contactTestBitMask = CollisionType.Rock.rawValue
        earth.physicsBody!.collisionBitMask = CollisionType.Rock.rawValue
        earthShield.physicsBody = SKPhysicsBody(texture: earthShieldTexture, size: CGSize(width: earthShield.size.width, height: earthShield.size.height))
        earthShield.physicsBody!.isDynamic = false
        earthShield.physicsBody!.categoryBitMask = CollisionType.Shield.rawValue
        earthShield.physicsBody!.contactTestBitMask = CollisionType.Rock.rawValue
        earthShield.physicsBody!.collisionBitMask = CollisionType.Rock.rawValue
        
        //we can actually add shield here , just hide it behind the earth, better for animation
        
        self.addChild(earth)
        self.addChild(startButton)
        
        //self.frame:width = 750, height = 1334
        
        print(timerLabel.position)
        print(timerLabel.fontName!)
        print(timerLabel.fontSize)
        //testing
        //self.addChild(testEarth)
        //finished testing
    }
    
    func spawnRockWithVelocity(Pos: CGPoint) {
        var rock = SKSpriteNode()
        rock = SKSpriteNode(texture: rockTexture)
        rock.setScale(earth.xScale)
        rock.physicsBody = SKPhysicsBody(circleOfRadius: rock.size.width / 2)
        rock.physicsBody!.affectedByGravity = false
        rock.physicsBody!.categoryBitMask = CollisionType.Rock.rawValue
        rock.physicsBody!.contactTestBitMask = CollisionType.Earth.rawValue | CollisionType.Shield.rawValue
        rock.physicsBody!.collisionBitMask = CollisionType.Earth.rawValue | CollisionType.Shield.rawValue
        
        
        //object = originalObject.copy()
        rock.position = Pos
        let velocity = CGVector(dx: (self.frame.midX - Pos.x) * rockVelocityScale, dy: (self.frame.midY - Pos.y) * rockVelocityScale)
        rock.physicsBody!.velocity = velocity
        self.addChild(rock)
        print("spawned a new rock at \(Pos)) with velocity of \(velocity)")
        //object.position.x += 30
        //self.addChild(object)
        //print(object.physicsBody!.velocity)
    }
    
    func spawnRockRandomly() {
        let randomDegree = CGFloat(2 * M_PI * drand48())
        let randomizedSpawnPoint = degreeToRandomizedPointOnRectangle(degreeInRadians: randomDegree, radius: halfFrameDiagnal)
        spawnRockWithVelocity(Pos: randomizedSpawnPoint)
    //
    }
    
    func degreeToRandomizedPointOnRectangle(degreeInRadians: CGFloat, radius: CGFloat) -> CGPoint {
        var xPos = CGFloat()
        var yPos = CGFloat()
        if degreeInRadians > CGFloat(2 * M_PI) - diagnalAngle || degreeInRadians <= diagnalAngle {
            xPos = self.frame.size.height / 2
            yPos = xPos * tan(degreeInRadians)
        } else if degreeInRadians > diagnalAngle && degreeInRadians <= CGFloat(M_PI) - diagnalAngle {
            yPos = self.frame.size.width / 2
            xPos = yPos / tan(degreeInRadians)
        } else if degreeInRadians > CGFloat(M_PI) - diagnalAngle && degreeInRadians <= CGFloat(M_PI) + diagnalAngle {
            xPos = -self.frame.size.height / 2
            yPos = xPos * tan(degreeInRadians)
        } else {
            yPos = -self.frame.size.width / 2
            xPos = yPos / tan(degreeInRadians)
        }
        return CGPoint(x: xPos, y: yPos)
    }
    

    
    func toggleRotationClockwise(object: SKSpriteNode) {
        object.zRotation -= rotationAngle
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if contact.bodyA.categoryBitMask == CollisionType.Shield.rawValue {
            print("blocked by shield")
        }
        if contact.bodyA.categoryBitMask == CollisionType.Earth.rawValue {
            print("absorbed by earth")
        }
        contact.bodyB.node?.removeFromParent()
        //spawnObjectWithVelocity(originalObject: rock, initialPos: CGPoint(x: self.frame.midX - self.frame.width / 2, y: self.frame.midY - self.frame.height / 2))
    }
    
    func touchDown(atPoint pos : CGPoint) {

    }
    
    func touchMoved(toPoint pos : CGPoint) {

    }
    
    
    func touchUp(atPoint pos : CGPoint) {

    }
    
    func gameStarts() {
        var wait = SKAction.wait(forDuration: self.rockSpawnInterval)
        let run = SKAction.run {
            self.timer += CGFloat(self.rockSpawnInterval)
            if self.rockSpawnInterval > 1 {
                self.rockSpawnInterval -= 0.05
            }
            wait = SKAction.wait(forDuration: self.rockSpawnInterval)
            self.spawnRockRandomly()
        }
        self.run(SKAction.repeatForever(SKAction.sequence([wait, run])))
        
    }
    func gameEnds() {
        self.removeAllActions()
        
    }
    func gameResets() {
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchInProgress = true
        if gameInProgress {
            spawnRockRandomly()
        }
    }
    
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchInProgress = false
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        //touchInProgress = false
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        if touchInProgress && !gameInProgress {
            gameInProgress = true
            self.addChild(earthShield)
            self.addChild(timerNode)
            self.addChild(scoreLabel)
            self.addChild(separatorLabel)
            self.addChild(timerLabel)
            startButton.removeFromParent()
            //gameStarts()
        }
        // Called before each frame is rendered
        if touchInProgress && gameInProgress {
            toggleRotationClockwise(object: earthShield)
        }
    }
}
