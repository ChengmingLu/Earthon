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
    var readyForRestart = false
    var beforeStart = true
    var earth = SKSpriteNode()
    var earthShield = SKSpriteNode()
    var startButton = SKSpriteNode()
    var timerLabel = SKLabelNode()
    var scoreLabel = SKLabelNode()
    var separatorLabel = SKLabelNode()
    var centerPoint = CGPoint()
    var rockTexture = SKTexture()
    var timerNode = SKNode()
    var rockVelocity = CGFloat()
    var halfFrameDiagnal = CGFloat()
    var dynamicDifficulty = CGFloat()
    var timer = Int()
    var score = Int(0)
    var diagnalAngle = CGFloat()
    var totalTimeAllowed = 10
    let objectRelativeScale = CGFloat(0.0002)
    let rockVelocityScale = CGFloat(0.3)
    let initialShieldOffset = CGFloat(-1.82)
    let rotationAngle = CGFloat(M_PI / 32)
    let timerLabelYPosOffset = CGFloat(6)
    let scoreLabelYPosOffset = CGFloat(-37)
    let separatorLabelYPosOffset = CGFloat(-3)
    let unitTimeInterval = TimeInterval(1)
    
    //need : high score label, touch to restart label, need to set high score initially to 0
    
    enum CollisionType: UInt32 {
        case Rock = 1
        case Shield = 2
        case Earth = 4
    }
    
    override func didMove(to view: SKView) {
        self.physicsWorld.contactDelegate = self
        timer = totalTimeAllowed
        halfFrameDiagnal = sqrt(pow(self.frame.size.width / 2, 2) + pow(self.frame.size.height / 2, 2))
        diagnalAngle = tanh(self.frame.size.width / self.frame.size.height)
        centerPoint = CGPoint(x: self.frame.midX, y: self.frame.midY)
        
        //texture settings
        let earthTexture = SKTexture(imageNamed: "EarthFG.png")
        let earthShieldTexture = SKTexture(imageNamed: "EarthShield.png")
        let startButtonTexture = SKTexture(imageNamed: "StartButton.png")
        rockTexture = SKTexture(imageNamed: "Rock.png")
        
        //initialize sprite nodes
        earth = SKSpriteNode(texture: earthTexture)
        earthShield = SKSpriteNode(texture: earthShieldTexture)
        startButton = SKSpriteNode(texture: startButtonTexture)
        
        //label settings
        timerLabel = SKLabelNode(fontNamed: "AppleSDGothicNeo-Regular")
        scoreLabel = SKLabelNode(fontNamed: "AppleSDGothicNeo-Regular")
        separatorLabel = SKLabelNode(fontNamed: "AppleSDGothicNeo-Bold")
        timerLabel.text = "\(timer)"
        scoreLabel.text = "0"
        separatorLabel.text = "___"
        
        //position, zposition and scale settings
        earth.position = centerPoint
        earth.zPosition = 4
        earthShield.position = centerPoint
        earthShield.zPosition = 3
        startButton.position = centerPoint
        startButton.zPosition = 7
        timerNode.zPosition = -1
        timerLabel.position = centerPoint
        timerLabel.position.y += timerLabelYPosOffset
        timerLabel.zPosition = 6
        scoreLabel.position = centerPoint
        scoreLabel.position.y += scoreLabelYPosOffset
        scoreLabel.zPosition = 6
        separatorLabel.position = centerPoint
        separatorLabel.position.y += separatorLabelYPosOffset
        separatorLabel.zPosition = 6
        earth.setScale(self.frame.size.width * objectRelativeScale)
        startButton.setScale(earth.xScale)
        earthShield.setScale(earth.xScale)
        
        //rotation and physics settings
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
        
        //initial alpha settings
        timerLabel.alpha = 0
        scoreLabel.alpha = 0
        separatorLabel.alpha = 0
        
        //we can actually add shield here , just hide it behind the earth, better for animation
        earthShield.setScale(0)
        self.addChild(earthShield)
        self.addChild(earth)
        self.addChild(startButton)
        self.addChild(timerNode)
        self.addChild(timerLabel)
        self.addChild(scoreLabel)
        self.addChild(separatorLabel)
        //self.frame:width = 750, height = 1334
        
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
        
        rock.position = Pos
        let velocity = CGVector(dx: (self.frame.midX - Pos.x) * rockVelocityScale, dy: (self.frame.midY - Pos.y) * rockVelocityScale)
        rock.physicsBody!.velocity = velocity
        self.addChild(rock)
    }
    
    func spawnRockRandomly() {
        let randomDegree = CGFloat(2 * M_PI * drand48())
        let randomizedSpawnPoint = degreeToRandomizedPointOnRectangle(degreeInRadians: randomDegree, radius: halfFrameDiagnal)
        spawnRockWithVelocity(Pos: randomizedSpawnPoint)
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
    
    func saveHighScore() {
        
    }
    
    func toggleRotationClockwise(object: SKSpriteNode) {
        object.zRotation -= rotationAngle
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if contact.bodyA.categoryBitMask == CollisionType.Rock.rawValue {
            if contact.bodyB.categoryBitMask == CollisionType.Shield.rawValue && contact.bodyA.node?.parent != nil {
                score += 1
                scoreLabel.text = "\(score)"
                contact.bodyA.node?.removeFromParent()
            } else if contact.bodyB.categoryBitMask == CollisionType.Earth.rawValue && contact.bodyA.node?.parent != nil {
                if gameInProgress {
                    score -= 1
                    scoreLabel.text = "\(score)"
                }
                contact.bodyA.node?.removeFromParent()
            }
        } else if contact.bodyB.categoryBitMask == CollisionType.Rock.rawValue {
            if contact.bodyA.categoryBitMask == CollisionType.Shield.rawValue && contact.bodyB.node?.parent != nil {
                score += 1
                scoreLabel.text = "\(score)"
                contact.bodyB.node?.removeFromParent()
            } else if contact.bodyA.categoryBitMask == CollisionType.Earth.rawValue && contact.bodyB.node?.parent != nil {
                if gameInProgress {
                    score -= 1
                    scoreLabel.text = "\(score)"
                }
                contact.bodyB.node?.removeFromParent()
            }
        }
    }
    
    func touchDown(atPoint pos : CGPoint) {
    }
    
    func touchMoved(toPoint pos : CGPoint) {
    }
    
    func touchUp(atPoint pos : CGPoint) {
    }
    
    func timerStarts() {
        let wait = SKAction.wait(forDuration: unitTimeInterval)
        let run = SKAction.run {
            if self.timer <= 1 {
                self.timerLabel.text = "0"
                self.gameInProgress = false
                self.removeAction(forKey: "TimerAction")
                //self.removeAllActions()
                let shieldRetract = SKAction.scale(to: 0, duration: 0.6)
                let timerLabelFade = SKAction.fadeAlpha(to: 0, duration: 0.3)
                let separatorLabelFade = SKAction.fadeAlpha(to: 0, duration: 0.3)
                let scoreUpLift = SKAction.moveBy(x: self.score >= 0 ? 0 : -10, y: 16, duration: 0.3)
                let scoreEmphasize = SKAction.scale(to: 1.5, duration: 0.5)
                let waitForRockToDisappear = SKAction.wait(forDuration: 3)
                let scoreActionSet = SKAction.sequence([scoreUpLift, scoreEmphasize, waitForRockToDisappear])
                self.earthShield.run(shieldRetract, completion: {
                    self.earthShield.removeFromParent()
                })
                self.timerLabel.run(timerLabelFade, completion: {
                    self.timerLabel.removeFromParent()
                })
                self.separatorLabel.run(separatorLabelFade, completion: {
                    self.separatorLabel.removeFromParent()
                })
                self.scoreLabel.run(scoreActionSet, completion: {
                    
                    //add label saying tap to restart, and high score label
                    
                    self.readyForRestart = true // might need to put this to new action
                })
                
                
            }
            self.timer -= 1
            self.timerLabel.text = "\(self.timer)"
        }
        let repeatedAction = SKAction.repeatForever(SKAction.sequence([wait, run]))
        self.run(repeatedAction, withKey: "TimerAction")
        
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
        if touchInProgress && beforeStart {
            beforeStart = false
            gameInProgress = true
            let startButtonScale = SKAction.scale(to: 0, duration: 0.3)
            let shieldExtractAction = SKAction.scale(to: self.earth.xScale, duration: 0.6)
            let timerAppear = SKAction.fadeAlpha(to: 1, duration: 0.3)
            let separatorAppear = SKAction.fadeAlpha(to: 1, duration: 0.3)
            let scoreAppear = SKAction.fadeAlpha(to: 1, duration: 0.3)
            startButton.run(startButtonScale, completion: {
                self.startButton.removeFromParent()
                //self.addChild(self.earthShield)
                self.earthShield.run(shieldExtractAction)
                self.timerLabel.run(timerAppear)
                self.separatorLabel.run(separatorAppear)
                self.scoreLabel.run(scoreAppear)
                self.timerStarts()
            })
        }
        if touchInProgress && !gameInProgress && readyForRestart{
            readyForRestart = false
            saveHighScore()
            score = 0
            scoreLabel.text = "\(score)"
            timer = totalTimeAllowed
            timerLabel.text = "\(timer)"
            //remove high score label, touch to restart label and
            // restore shield, timer, separator and score, enable touch to spawn red
            //kicks timer
            let shieldRestoration = SKAction.scale(to: self.earth.xScale, duration: 0.6)
            let timerAppear = SKAction.fadeAlpha(to: 1, duration: 0.3)
            let separatorAppear = SKAction.fadeAlpha(to: 1, duration: 0.3)
            let scoreMoveDown = SKAction.moveBy(x: 0, y: -16, duration: 0.3)
            let scoreShrink = SKAction.scale(to: 1, duration: 0.3)
            let waitForAllAnimation = SKAction.wait(forDuration: 1)
            let scoreActionSet = SKAction.sequence([scoreMoveDown, scoreShrink, waitForAllAnimation])
            timerLabel.alpha = 0
            separatorLabel.alpha = 0
            earthShield.xScale = 0
            self.addChild(timerLabel)
            self.addChild(separatorLabel)
            self.addChild(earthShield)

            earthShield.run(shieldRestoration)
            timerLabel.run(timerAppear)
            separatorLabel.run(separatorAppear)
            //earthShield.
            scoreLabel.run(scoreActionSet, completion: {
                self.gameInProgress = true
                self.spawnRockRandomly()
                self.timerStarts()
            })
        }
        // Called before each frame is rendered
        if touchInProgress && gameInProgress {
            toggleRotationClockwise(object: earthShield)
        }
    }
}
